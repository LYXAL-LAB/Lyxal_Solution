// SPDX-License-Identifier: AGPL-3.0-only

//! Contrôles lancés pendant le dialogue et attendus à la fin des données (plan du lot 5, §6) :
//! nom inverse dès la connexion, SPF de HELO dès `EHLO`, SPF de `MAIL FROM` dès la commande.
//! Chaque contrôle est un futur possédé par la session, avancé pendant qu'elle attend le client
//! (aucune tâche de fond hors de la session : rien ne survit à la connexion), puis attendu
//! quand son résultat est nécessaire.

use std::future::{poll_fn, Future};
use std::pin::Pin;
use std::task::{Context, Poll};

use crate::auth::{IprevOutput, SpfOutput};

type BoxFuture<T> = Pin<Box<dyn Future<Output = T> + Send + 'static>>;

/// Un contrôle : absent, en cours ou terminé.
pub(crate) enum Pending<T> {
    Empty,
    Running(BoxFuture<T>),
    Done(T),
}

impl<T> Pending<T> {
    pub(crate) fn start(&mut self, future: impl Future<Output = T> + Send + 'static) {
        *self = Self::Running(Box::pin(future));
    }

    pub(crate) fn clear(&mut self) {
        *self = Self::Empty;
    }

    fn running(&self) -> bool {
        matches!(self, Self::Running(_))
    }

    /// Avance le contrôle ; prêt quand il vient de se terminer.
    fn poll_step(&mut self, cx: &mut Context<'_>) -> Poll<()> {
        if let Self::Running(future) = self {
            if let Poll::Ready(value) = future.as_mut().poll(cx) {
                *self = Self::Done(value);
                return Poll::Ready(());
            }
        }
        Poll::Pending
    }

    /// Résultat, attendu s'il est en cours ; `None` si aucun contrôle n'a été lancé.
    pub(crate) async fn result(&mut self) -> Option<&T> {
        if let Self::Running(future) = self {
            let value = future.as_mut().await;
            *self = Self::Done(value);
        }
        match self {
            Self::Done(value) => Some(value),
            _ => None,
        }
    }
}

/// Contrôles d'une session.
pub(crate) struct Checks {
    pub(crate) iprev: Pending<IprevOutput>,
    pub(crate) helo_spf: Pending<SpfOutput>,
    pub(crate) mail_spf: Pending<SpfOutput>,
}

impl Checks {
    pub(crate) fn new() -> Self {
        Self {
            iprev: Pending::Empty,
            helo_spf: Pending::Empty,
            mail_spf: Pending::Empty,
        }
    }

    /// Vrai si un contrôle est en cours.
    pub(crate) fn running(&self) -> bool {
        self.iprev.running() || self.helo_spf.running() || self.mail_spf.running()
    }

    /// Avance les contrôles en cours jusqu'à ce que l'un d'eux se termine (en attente
    /// indéfinie s'il n'y en a aucun : à n'utiliser qu'avec [`Checks::running`]).
    pub(crate) async fn progress(&mut self) {
        poll_fn(|cx| {
            let iprev = self.iprev.poll_step(cx);
            let helo = self.helo_spf.poll_step(cx);
            let mail = self.mail_spf.poll_step(cx);
            if iprev.is_ready() || helo.is_ready() || mail.is_ready() {
                Poll::Ready(())
            } else {
                Poll::Pending
            }
        })
        .await;
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn a_check_progresses_while_waiting_and_is_kept() {
        let mut pending: Pending<u32> = Pending::Empty;
        assert!(pending.result().await.is_none());
        pending.start(async { 7 });
        assert!(pending.running());
        assert_eq!(pending.result().await, Some(&7));
        assert_eq!(pending.result().await, Some(&7));
        pending.clear();
        assert!(pending.result().await.is_none());
    }
}
