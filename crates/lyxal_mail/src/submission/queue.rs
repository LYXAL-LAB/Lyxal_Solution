// SPDX-License-Identifier: AGPL-3.0-only

//! Mise en file d'un message déposé (plan du lot 6, §8.5, étape 6) : trois allers-retours.
//!
//! 1. `fn::mail_submission_begin` **au nom de l'utilisateur** (droit d'expéditeur, destinataires,
//!    taille, limites d'envoi prises) : envoi `pending` et clé du fichier ;
//! 2. écriture chiffrée du fichier par `lyxal_storage` sous la session système de l'hôte, dans le
//!    bucket `lyxal-mail` de l'organisation (créé s'il manque) ;
//! 3. `fn::mail_submission_commit` sous la session système : fichier contrôlé, destinataires en
//!    file, en une transaction.
//!
//! Atomicité : une écriture du fichier en échec fait abandonner l'envoi
//! (`fn::mail_submission_abort` au nom de l'utilisateur, compteurs rendus) ; une clôture refusée
//! par la base fait supprimer le fichier, que rien ne référence, et abandonner l'envoi ; une
//! panne dont on ne sait pas si la clôture a eu lieu ne fait rien supprimer : l'envoi `pending`
//! et son fichier sont retirés par la maintenance au bout d'une heure (`fn::mail_queue_purge`).

use bytes::Bytes;
use lyxal_surreal::ToSql;

use crate::error::{MailError, MailResult};
use crate::ingest::{retry_conflicts, MailIngest};
use crate::models::{
    SubmissionBeginParams, SubmissionCommitParams, SubmissionQueued, SubmissionRefParams,
};
use crate::store::MailStore;

impl MailIngest {
    /// Inscrit un message déposé dans la file d'envoi : `begin` sous la session de l'appelant
    /// (`caller`), fichier et clôture sous la session système de l'hôte. `params.size` doit être
    /// la taille de `raw`.
    pub async fn queue_submission(
        &self,
        caller: &MailStore,
        params: SubmissionBeginParams,
        raw: Bytes,
    ) -> MailResult<SubmissionQueued> {
        if !self.is_available() {
            return Err(MailError::Unavailable(
                "stockage chiffré indisponible (support ou clé maîtresse)".to_string(),
            ));
        }
        let size = raw.len() as u64;
        let reserved = retry_conflicts(|| caller.submission_begin(params.clone())).await?;
        let submission = reserved.submission.to_sql();
        let object = match self
            .write_file(
                &reserved.tenant,
                &reserved.bucket_name,
                &reserved.key,
                raw,
                size,
            )
            .await
        {
            Ok(object) => object,
            Err(error) => {
                self.release(caller, &submission).await;
                return Err(error);
            }
        };
        let commit = SubmissionCommitParams {
            submission: submission.clone(),
            object: object.clone(),
        };
        match retry_conflicts(|| self.system().submission_commit(commit.clone())).await {
            Ok(queued) => Ok(queued),
            Err(error) => {
                let error = MailError::from(error);
                if !error.is_business() {
                    return Err(error);
                }
                let error = self.abandon(&object, error).await;
                self.release(caller, &submission).await;
                Err(error)
            }
        }
    }

    /// Abandon d'un envoi non clos (compteurs rendus) ; un échec est journalisé, l'envoi est
    /// retiré par la maintenance à la fin de son délai.
    async fn release(&self, caller: &MailStore, submission: &str) {
        let params = SubmissionRefParams {
            submission: submission.to_string(),
        };
        if let Err(error) = caller.submission_abort(params).await {
            tracing::warn!(code = %MailError::from(error).code(), "dépôt non abandonné : retiré par la maintenance");
        }
    }
}
