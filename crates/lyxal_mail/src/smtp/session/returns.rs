// SPDX-License-Identifier: AGPL-3.0-only

//! Adresses de retour et transferts à la réception du port 25 (plan du lot 6, §10.3, §11, §13 ;
//! décisions E21, E23, E25).
//!
//! * `RCPT TO:<rp=<jeton>@<domaine>>` : adresse de retour d'un envoi, acceptée seulement si le
//!   jeton est connu et non échu (`fn::mail_recipient_resolve`, sinon `550 5.1.1`) ; le message
//!   est lu par le chemin de réception commun ([`crate::delivery::Reception`] : antivirus une
//!   fois, puis remise aux boîtes ordinaires, avis, transferts), jamais réexpédié vers
//!   l'extérieur ;
//! * alias à cibles extérieures (`forward_to`) : retenus à `RCPT TO`, transférés par le même
//!   chemin ; la réception d'origine gardée pour l'avis ([`forward_origin`]) est celle du
//!   port 25 : adresse d'enveloppe, SPF sur `MAIL FROM`, DKIM du domaine de l'enveloppe (§10.2) ;
//! * la réponse `250` n'est donnée qu'après la remise, l'inscription des avis et la mise en file
//!   des transferts ; une panne de l'une de ces étapes : `451`, l'expéditeur réessaie (remises,
//!   avis et transferts rejouables sans doublon).

use super::*;
use crate::auth::OrganizationalDomain;
use crate::dsn::ReturnTarget;
use crate::models::ForwardReception;

/// Vrai si une signature DKIM valide porte le domaine de l'adresse d'enveloppe `sender` ou son
/// domaine d'organisation (§10.2) : un `From` aligné ne prouve rien sur l'enveloppe.
fn envelope_dkim(
    sender: &str,
    dkim: &[DkimOutput],
    organizational: &dyn OrganizationalDomain,
) -> bool {
    let Some(domain) = sender
        .rsplit_once('@')
        .and_then(|(_, domain)| to_ascii_domain(domain))
    else {
        return false;
    };
    let organization = organizational.organizational_domain(&domain);
    dkim.iter()
        .filter(|output| output.result == DkimResult::Pass && !output.testing)
        .filter_map(|output| output.domain.as_deref())
        .any(|signer| signer == domain || organization.as_deref() == Some(signer))
}

/// Réception d'origine gardée sur les transferts de la transaction : adresse d'enveloppe, SPF
/// sur l'identité `MAIL FROM` (sinon `none`), DKIM du domaine de l'enveloppe.
pub(super) fn forward_origin(
    transaction: &Transaction,
    spf: &SpfOutput,
    dkim: &[DkimOutput],
    organizational: &dyn OrganizationalDomain,
) -> ForwardReception {
    ForwardReception {
        envelope_from: (!transaction.sender.is_empty()).then(|| transaction.sender.clone()),
        spf: if spf.identity == SpfIdentity::MailFrom {
            spf.result.as_str()
        } else {
            "none"
        }
        .to_string(),
        envelope_dkim: envelope_dkim(&transaction.sender, dkim, organizational),
    }
}

impl SmtpSession {
    /// `RCPT TO` d'une adresse de retour valide.
    pub(super) async fn accept_return(
        &mut self,
        resolved: ResolvedRecipient,
        declared: Option<u64>,
    ) -> Flow {
        let (Some(submission), Some(origin)) = (resolved.submission.clone(), resolved.origin)
        else {
            return self.refuse_recipient(RefusedReason::Unknown).await;
        };
        let max = u64::try_from(resolved.max_message_bytes).unwrap_or(0);
        if declared.is_some_and(|size| size > max) {
            self.io.reply(
                552,
                "5.3.4",
                "Message size exceeds the recipient's maximum message size",
            );
            self.shared.metrics.recipient_refused(RefusedReason::Size);
            return Flow::Continue;
        }
        let Some(transaction) = self.transaction.as_mut() else {
            return Flow::Continue;
        };
        if !transaction
            .returns
            .iter()
            .any(|known| known.address == resolved.address)
        {
            transaction.max_bytes = transaction.max_bytes.min(max);
            transaction.returns.push(ReturnTarget {
                address: resolved.address,
                tenant: resolved.tenant,
                submission,
                origin,
                account: resolved.account,
            });
        }
        transaction.accepted += 1;
        self.shared.metrics.recipient_accepted();
        self.io.reply(250, "2.1.5", "Recipient OK");
        Flow::Continue
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used)]
mod tests {
    use super::*;
    use crate::auth::EmbeddedSuffixList;

    fn signature(result: DkimResult, domain: &str) -> DkimOutput {
        DkimOutput {
            result,
            domain: Some(domain.to_string()),
            selector: None,
            signature_prefix: None,
            testing: false,
        }
    }

    #[test]
    fn only_a_valid_signature_of_the_envelope_domain_counts() {
        let psl = EmbeddedSuffixList;
        let sender = "bounce@mail.ailleurs.com";
        assert!(envelope_dkim(
            sender,
            &[signature(DkimResult::Pass, "mail.ailleurs.com")],
            &psl
        ));
        assert!(envelope_dkim(
            sender,
            &[signature(DkimResult::Pass, "ailleurs.com")],
            &psl
        ));
        assert!(!envelope_dkim(
            sender,
            &[signature(DkimResult::Fail, "ailleurs.com")],
            &psl
        ));
        assert!(!envelope_dkim(
            sender,
            &[signature(DkimResult::Pass, "autre.com")],
            &psl
        ));
        assert!(!envelope_dkim(
            "",
            &[signature(DkimResult::Pass, "ailleurs.com")],
            &psl
        ));
        let mut testing = signature(DkimResult::Pass, "ailleurs.com");
        testing.testing = true;
        assert!(!envelope_dkim(sender, &[testing], &psl));
    }
}
