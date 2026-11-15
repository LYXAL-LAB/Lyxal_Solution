//! Contrats Rust des 38 fonctions publiques du lot 1, en base embarquée : chaque `XxxParams`
//! est accepté tel quel (le lot 1 refuse les clés inconnues), chaque résultat se décode sans
//! perte, et une erreur métier garde son code.

use crate::support::{bench, lossless, raw};
use jiff::{SignedDuration, Timestamp};
use lyxal_scheduler::models::*;
use lyxal_scheduler::spec::{to_datetime, to_duration, to_timestamp};
use lyxal_scheduler::{CalendarSet, SchedulerError, Spec};
use lyxal_surreal::{RecordId, Value};

fn alpha() -> RecordId {
    RecordId::new("auth_organization", "alpha")
}

/// Maintenant décalé de `secs` secondes.
fn now_plus(secs: i64) -> SchedulerDatetime {
    to_datetime(
        Timestamp::now()
            .checked_add(SignedDuration::from_secs(secs))
            .expect("date"),
    )
    .expect("date")
}

fn secs(n: i64) -> SchedulerDuration {
    to_duration(SignedDuration::from_secs(n)).expect("durée")
}

fn object(pairs: &[(&str, &str)]) -> SchedulerValue {
    let mut object = surrealdb::types::Object::new();
    for (k, v) in pairs {
        object.insert(*k, v.to_string());
    }
    Value::Object(object)
}

fn daily_paris() -> ScheduleSpec {
    let mut spec = ScheduleSpec::new("Europe/Paris");
    spec.cron = vec!["0 9 * * *".to_string()];
    spec.exclude_cron = vec!["0 9 25 12 *".to_string()];
    spec.jitter = Some(secs(60));
    spec
}

fn schedule_params(name: &str) -> ScheduleCreateParams {
    let mut params = ScheduleCreateParams::new(name, "essai.rapport", daily_paris());
    params.tenant = Some(alpha());
    params.args = Some(object(&[("format", "pdf")]));
    params.overlap = Some(Overlap::AllowAll);
    params.catchup = Some(Catchup::All);
    params
}

fn expect_code<T: std::fmt::Debug>(result: Result<T, impl Into<SchedulerError>>, code: &str) {
    match result {
        Ok(value) => panic!("erreur {code} attendue, obtenu {value:?}"),
        Err(error) => {
            let error: SchedulerError = error.into();
            assert_eq!(error.code(), code, "{error}");
        }
    }
}

#[tokio::test]
async fn settings_tasks_queues_and_audit() {
    let (_client, store, _service) = bench().await;

    // settings_get / settings_set
    let installation = store
        .settings_get(SettingsGetParams::default())
        .await
        .expect("réglages");
    assert!(installation.own.is_none());
    assert_eq!(installation.effective.keep_last_runs, 10);
    let set = store
        .settings_set(SettingsSetParams {
            tenant: Some(alpha()),
            catchup_window: Some(secs(7200)),
            keep_last_runs: Some(5),
            clear: Some(vec!["max_schedules".to_string()]),
            language: Some("en".to_string()),
            ..SettingsSetParams::default()
        })
        .await
        .expect("réglages enregistrés");
    assert_eq!(set.effective.catchup_window, secs(7200));
    assert_eq!(set.own.as_ref().and_then(|o| o.keep_last_runs), Some(5));
    let full: SettingsResult = lossless(
        raw(
            &store,
            "scheduler_settings_get",
            SettingsGetParams {
                tenant: Some(alpha()),
                language: None,
            },
        )
        .await,
        &[],
    );
    assert_eq!(full, set);

    // task_list / task_get / task_set_state
    let tasks = store
        .task_list(TaskListParams {
            module: Some("lyxal_essai".to_string()),
            ..TaskListParams::default()
        })
        .await
        .expect("tâches");
    assert_eq!(tasks.total, 2);
    let _: Page<Task> = lossless(
        raw(&store, "scheduler_task_list", TaskListParams::default()).await,
        &[],
    );
    let task = store
        .task_get(TaskGetParams {
            task: "essai.rapport".to_string(),
            language: None,
        })
        .await
        .expect("tâche");
    assert_eq!(
        (task.executor, task.scope, task.retry.strategy),
        (
            Executor::Handler,
            TaskScope::Organization,
            RetryStrategy::Exponential
        )
    );
    let raw_task: Task = lossless(
        raw(
            &store,
            "scheduler_task_get",
            TaskGetParams {
                task: "essai.global".to_string(),
                language: None,
            },
        )
        .await,
        &[],
    );
    assert_eq!(raw_task.scope, TaskScope::Installation);
    let disabled = store
        .task_set_state(TaskSetStateParams {
            task: "essai.global".to_string(),
            state: TaskState::Disabled,
            language: None,
        })
        .await
        .expect("désactivée");
    assert_eq!(disabled.state, TaskState::Disabled);
    let _: Task = lossless(
        raw(
            &store,
            "scheduler_task_set_state",
            TaskSetStateParams {
                task: "essai.global".to_string(),
                state: TaskState::Active,
                language: None,
            },
        )
        .await,
        &[],
    );
    expect_code(
        store
            .task_get(TaskGetParams {
                task: "essai.absente".to_string(),
                language: None,
            })
            .await,
        "SCHEDULER_TASK_NOT_FOUND",
    );

    // queue_list / queue_pause / queue_resume
    let queues = store
        .queue_list(QueueListParams::default())
        .await
        .expect("files");
    assert_eq!(queues.len(), 2);
    let _: Vec<Queue> = lossless(
        raw(&store, "scheduler_queue_list", QueueListParams::default()).await,
        &[],
    );
    let paused = store
        .queue_pause(QueuePauseParams {
            queue: "maintenance".to_string(),
            reason: Some("essai".to_string()),
            language: None,
        })
        .await
        .expect("pause");
    assert!(paused.paused);
    let resumed = store
        .queue_resume(QueueResumeParams {
            queue: "maintenance".to_string(),
            language: None,
        })
        .await
        .expect("reprise");
    assert!(!resumed.paused);
    let _: Queue = lossless(
        raw(
            &store,
            "scheduler_queue_pause",
            QueuePauseParams {
                queue: "default".to_string(),
                reason: None,
                language: None,
            },
        )
        .await,
        &[],
    );
    let _: Queue = lossless(
        raw(
            &store,
            "scheduler_queue_resume",
            QueueResumeParams {
                queue: "default".to_string(),
                language: None,
            },
        )
        .await,
        &[],
    );
    expect_code(
        store
            .queue_pause(QueuePauseParams {
                queue: "absente".to_string(),
                reason: None,
                language: None,
            })
            .await,
        "SCHEDULER_QUEUE_NOT_FOUND",
    );

    // audit_list : les réglages modifiés sont journalisés
    let audit = store
        .audit_list(AuditListParams {
            tenant: Some(alpha()),
            ..AuditListParams::default()
        })
        .await
        .expect("journal");
    assert!(audit.total >= 1, "{audit:?}");
    let _: Page<AuditEntry> = lossless(
        raw(
            &store,
            "scheduler_audit_list",
            AuditListParams {
                tenant: Some(alpha()),
                ..AuditListParams::default()
            },
        )
        .await,
        &[],
    );
}

#[tokio::test]
async fn calendars_and_schedules() {
    let (_client, store, service) = bench().await;
    let working = vec![
        CalendarRule {
            mode: RuleMode::Include,
            kind: RuleKind::Weekdays,
            values: (1..=5).map(Value::from_t).collect(),
        },
        CalendarRule {
            mode: RuleMode::Exclude,
            kind: RuleKind::TimeRange,
            values: vec![Value::from_t("12:00-14:00".to_string())],
        },
    ];

    // calendar_create / _update / _get / _list / _delete
    let calendar = store
        .calendar_create(CalendarCreateParams {
            tenant: Some(alpha()),
            name: "jours-ouvres".to_string(),
            description: Some("Jours ouvrés".to_string()),
            rules: working.clone(),
            language: None,
        })
        .await
        .expect("calendrier");
    assert_eq!(calendar.rules, working);
    let holidays: Calendar = lossless(
        raw(
            &store,
            "scheduler_calendar_create",
            CalendarCreateParams {
                tenant: Some(alpha()),
                name: "feries".to_string(),
                description: None,
                rules: vec![CalendarRule {
                    mode: RuleMode::Exclude,
                    kind: RuleKind::Annual,
                    values: vec![
                        Value::from_t("12-25".to_string()),
                        Value::from_t("05-01".to_string()),
                    ],
                }],
                language: None,
            },
        )
        .await,
        &[],
    );
    let updated = store
        .calendar_update(CalendarUpdateParams {
            calendar: holidays.id.clone(),
            description: None,
            rules: None,
            clear: Some(vec!["description".to_string()]),
            language: None,
        })
        .await
        .expect("modifié");
    assert_eq!(updated.description, None);
    let _: Calendar = lossless(
        raw(
            &store,
            "scheduler_calendar_update",
            CalendarUpdateParams {
                calendar: holidays.id.clone(),
                description: Some("Fériés".to_string()),
                rules: None,
                clear: None,
                language: None,
            },
        )
        .await,
        &[],
    );
    let got = store
        .calendar_get(CalendarRefParams {
            calendar: calendar.id.clone(),
            language: None,
        })
        .await
        .expect("lu");
    assert_eq!(got.schedules, Some(Vec::new()));
    let _: Calendar = lossless(
        raw(
            &store,
            "scheduler_calendar_get",
            CalendarRefParams {
                calendar: calendar.id.clone(),
                language: None,
            },
        )
        .await,
        &[],
    );
    let list = store
        .calendar_list(CalendarListParams {
            tenant: Some(alpha()),
            limit: Some(1),
            ..CalendarListParams::default()
        })
        .await
        .expect("liste");
    assert_eq!((list.items.len(), list.total), (1, 2));
    let _: Page<Calendar> = lossless(
        raw(
            &store,
            "scheduler_calendar_list",
            CalendarListParams {
                tenant: Some(alpha()),
                ..CalendarListParams::default()
            },
        )
        .await,
        &[],
    );

    // schedule_create par le service (contrôle des dates) et par le store
    let mut params = schedule_params("rapport");
    params.calendars = Some(vec![calendar.id.clone(), holidays.id.clone()]);
    params.remaining = Some(100);
    params.catchup_window = Some(secs(600));
    params.pause_on_failure = Some(true);
    let schedule = service
        .schedule_create(params)
        .await
        .expect("planification");
    assert_eq!(schedule.spec, daily_paris());
    assert_eq!(
        (schedule.state, schedule.next_fire_at.is_none()),
        (ScheduleState::Active, true)
    );
    let mut second = schedule_params("rapport-brut");
    second.paused = Some(true);
    second.paused_reason = Some("essai".to_string());
    let brut: Schedule = lossless(raw(&store, "scheduler_schedule_create", second).await, &[]);
    assert!(brut.paused);

    // Règles refusées par le calcul avant toute écriture
    let mut bad = schedule_params("mauvaise");
    bad.spec.cron = vec!["0 9 * * * * * *".to_string()];
    expect_code(service.schedule_create(bad).await, "SCHEDULER_SPEC_INVALID");
    let mut bad = schedule_params("mauvaise");
    bad.spec.timezone = "Mars/Olympus".to_string();
    match service.schedule_create(bad).await {
        Err(SchedulerError::Spec(e)) => assert_eq!(
            (e.rule.as_str(), e.reason),
            ("timezone", lyxal_scheduler::SpecReason::Timezone)
        ),
        other => panic!("fuseau refusé attendu : {other:?}"),
    }
    let mut bad = schedule_params("mauvaise");
    bad.calendars = Some(vec![RecordId::new("scheduler_calendar", "absent")]);
    expect_code(
        service.schedule_create(bad).await,
        "SCHEDULER_CALENDAR_NOT_FOUND",
    );
    expect_code(
        store
            .schedule_get(ScheduleRefParams {
                schedule: RecordId::new("scheduler_schedule", "absente"),
                language: None,
            })
            .await,
        "SCHEDULER_SCHEDULE_NOT_FOUND",
    );

    // schedule_update par le service et par le store
    let mut change = ScheduleUpdateParams::new(schedule.id.clone());
    let mut spec = daily_paris();
    spec.cron = vec!["30 8 * * 1-5".to_string()];
    change.spec = Some(spec.clone());
    change.overlap = Some(Overlap::Skip);
    change.catchup = Some(Catchup::Last);
    change.clear = Some(vec!["remaining".to_string()]);
    let changed = service.schedule_update(change).await.expect("modifiée");
    assert_eq!(
        (changed.spec.cron.clone(), changed.remaining),
        (spec.cron.clone(), None)
    );
    let mut bad = ScheduleUpdateParams::new(schedule.id.clone());
    let mut wrong = daily_paris();
    wrong.every = vec![secs(10)];
    bad.spec = Some(wrong);
    expect_code(service.schedule_update(bad).await, "SCHEDULER_SPEC_INVALID");
    let mut direct = ScheduleUpdateParams::new(brut.id.clone());
    direct.args = Some(object(&[("format", "csv")]));
    direct.catchup_window = Some(secs(120));
    direct.pause_on_failure = Some(false);
    direct.remaining = Some(3);
    direct.calendars = Some(vec![holidays.id.clone()]);
    let _: Schedule = lossless(raw(&store, "scheduler_schedule_update", direct).await, &[]);

    // forecast et validate_spec
    let forecast = service
        .forecast(schedule.id.clone(), 5)
        .await
        .expect("prévision");
    assert_eq!(forecast.len(), 5);
    assert!(
        forecast
            .iter()
            .all(|f| f.local.contains("08:30:00") && f.local.ends_with("[Europe/Paris]")),
        "{forecast:?}"
    );
    service
        .validate_spec(&daily_paris(), std::slice::from_ref(&calendar.id), None)
        .await
        .expect("règles valides");

    // schedule_get / _list / _pause / _resume
    let read = store
        .schedule_get(ScheduleRefParams {
            schedule: schedule.id.clone(),
            language: None,
        })
        .await
        .expect("lue");
    assert_eq!(read.calendars.len(), 2);
    let _: Schedule = lossless(
        raw(
            &store,
            "scheduler_schedule_get",
            ScheduleRefParams {
                schedule: schedule.id.clone(),
                language: None,
            },
        )
        .await,
        &[],
    );
    let page = store
        .schedule_list(ScheduleListParams {
            tenant: Some(alpha()),
            task: Some("essai.rapport".to_string()),
            state: Some(ScheduleState::Active),
            paused: Some(false),
            ..ScheduleListParams::default()
        })
        .await
        .expect("liste");
    assert_eq!(page.total, 1);
    let _: Page<Schedule> = lossless(
        raw(
            &store,
            "scheduler_schedule_list",
            ScheduleListParams {
                tenant: Some(alpha()),
                ..ScheduleListParams::default()
            },
        )
        .await,
        &[],
    );
    let paused = store
        .schedule_pause(SchedulePauseParams {
            schedule: schedule.id.clone(),
            reason: Some("vacances".to_string()),
            language: None,
        })
        .await
        .expect("pause");
    assert_eq!(paused.paused_reason.as_deref(), Some("vacances"));
    let resumed = store
        .schedule_resume(ScheduleRefParams {
            schedule: schedule.id.clone(),
            language: None,
        })
        .await
        .expect("reprise");
    assert!(!resumed.paused);
    let _: Schedule = lossless(
        raw(
            &store,
            "scheduler_schedule_resume",
            ScheduleRefParams {
                schedule: brut.id.clone(),
                language: None,
            },
        )
        .await,
        &[],
    );
    let _: Schedule = lossless(
        raw(
            &store,
            "scheduler_schedule_pause",
            SchedulePauseParams {
                schedule: brut.id.clone(),
                reason: None,
                language: None,
            },
        )
        .await,
        &[],
    );

    // calendar_delete : refusé tant qu'il est utilisé, puis supprimé
    expect_code(
        store
            .calendar_delete(CalendarRefParams {
                calendar: calendar.id.clone(),
                language: None,
            })
            .await,
        "SCHEDULER_CALENDAR_IN_USE",
    );

    // schedule_delete puis calendar_delete
    let deleted = store
        .schedule_delete(ScheduleRefParams {
            schedule: schedule.id.clone(),
            language: None,
        })
        .await
        .expect("supprimée");
    assert!(deleted.deleted.starts_with("scheduler_schedule:"));
    let _: Deleted = lossless(
        raw(
            &store,
            "scheduler_schedule_delete",
            ScheduleRefParams {
                schedule: brut.id.clone(),
                language: None,
            },
        )
        .await,
        &[],
    );
    let gone = store
        .calendar_delete(CalendarRefParams {
            calendar: calendar.id.clone(),
            language: None,
        })
        .await
        .expect("supprimé");
    assert!(gone.deleted.starts_with("scheduler_calendar:"));
    let _: Deleted = lossless(
        raw(
            &store,
            "scheduler_calendar_delete",
            CalendarRefParams {
                calendar: holidays.id.clone(),
                language: None,
            },
        )
        .await,
        &[],
    );
}

#[tokio::test]
async fn runs_of_people_and_modules() {
    let (_client, store, service) = bench().await;
    let schedule = service
        .schedule_create(schedule_params("rapport"))
        .await
        .expect("planification");

    // schedule_trigger
    let triggered = store
        .schedule_trigger(ScheduleTriggerParams {
            schedule: schedule.id.clone(),
            overlap: Some(Overlap::AllowAll),
            language: None,
        })
        .await
        .expect("déclenchée");
    assert_eq!(
        (triggered.origin, triggered.state),
        (RunOrigin::Trigger, RunState::Queued)
    );
    let _: Run = lossless(
        raw(
            &store,
            "scheduler_schedule_trigger",
            ScheduleTriggerParams {
                schedule: schedule.id.clone(),
                overlap: None,
                language: None,
            },
        )
        .await,
        &["lease"],
    );

    // run_enqueue (délai, puis date) — duplicate rendu
    let mut enqueue = RunEnqueueParams::new("essai.rapport");
    enqueue.tenant = Some(alpha());
    enqueue.args = Some(object(&[("format", "csv")]));
    enqueue.delay = Some(secs(3600));
    enqueue.priority = Some(2);
    enqueue.unique_key = Some("cle".to_string());
    enqueue.language = Some("fr".to_string());
    let delayed = store.run_enqueue(enqueue).await.expect("différée");
    assert_eq!(
        (delayed.duplicate, delayed.priority, delayed.origin),
        (Some(false), 2, RunOrigin::Enqueue)
    );
    let mut at = RunEnqueueParams::new("essai.global");
    at.run_at = Some(now_plus(600));
    let global: Run = lossless(raw(&store, "scheduler_run_enqueue", at).await, &["lease"]);
    assert_eq!(global.tenant, None);
    let mut both = RunEnqueueParams::new("essai.global");
    both.run_at = Some(now_plus(600));
    both.delay = Some(secs(60));
    expect_code(
        store.run_enqueue(both).await,
        "SCHEDULER_INVALID_PARAMETERS",
    );

    // run_get / run_list
    let read = store
        .run_get(RunRefParams {
            run: delayed.id.clone(),
            language: None,
        })
        .await
        .expect("lue");
    assert_eq!(read.unique_key.as_deref(), Some("cle"));
    let _: Run = lossless(
        raw(
            &store,
            "scheduler_run_get",
            RunRefParams {
                run: triggered.id.clone(),
                language: None,
            },
        )
        .await,
        &["lease"],
    );
    let page = store
        .run_list(RunListParams {
            tenant: Some(alpha()),
            schedule: Some(schedule.id.clone()),
            task: Some("essai.rapport".to_string()),
            state: Some(RunState::Queued),
            since: Some(now_plus(-3600)),
            limit: Some(10),
            start: Some(0),
            language: None,
        })
        .await
        .expect("liste");
    assert_eq!(page.total, 2);
    let _: Page<Run> = lossless(
        raw(
            &store,
            "scheduler_run_list",
            RunListParams {
                tenant: Some(alpha()),
                ..RunListParams::default()
            },
        )
        .await,
        &["lease"],
    );

    // run_cancel puis run_retry
    let cancelled = store
        .run_cancel(RunCancelParams {
            run: delayed.id.clone(),
            reason: Some("inutile".to_string()),
            language: None,
        })
        .await
        .expect("annulée");
    assert_eq!(cancelled.state, RunState::Cancelled);
    let retried = store
        .run_retry(RunRefParams {
            run: delayed.id.clone(),
            language: None,
        })
        .await
        .expect("relancée");
    assert_eq!(
        (retried.origin, retried.retry_of.clone()),
        (
            RunOrigin::Retry,
            Some(lyxal_surreal::ToSql::to_sql(&delayed.id))
        )
    );
    let other: Run = lossless(
        raw(
            &store,
            "scheduler_run_cancel",
            RunCancelParams {
                run: global.id.clone(),
                reason: None,
                language: None,
            },
        )
        .await,
        &["lease"],
    );
    assert_eq!(other.state, RunState::Cancelled);
    let _: Run = lossless(
        raw(
            &store,
            "scheduler_run_retry",
            RunRefParams {
                run: global.id.clone(),
                language: None,
            },
        )
        .await,
        &["lease"],
    );
    expect_code(
        store
            .run_cancel(RunCancelParams {
                run: delayed.id.clone(),
                reason: None,
                language: None,
            })
            .await,
        "SCHEDULER_RUN_STATE_INVALID",
    );
}

#[tokio::test]
async fn engine_and_workers() {
    let (client, store, service) = bench().await;
    let first = service
        .schedule_create(schedule_params("premiere"))
        .await
        .expect("planification");
    let second = service
        .schedule_create(schedule_params("seconde"))
        .await
        .expect("planification");
    let third = service
        .schedule_create(schedule_params("troisieme"))
        .await
        .expect("planification");

    // due_list : planifications à calculer, avec règles et calendriers
    let due = store
        .due_list(DueListParams {
            limit: Some(10),
            language: None,
        })
        .await
        .expect("dues");
    assert_eq!(due.schedules.len(), 3);
    assert!(due
        .schedules
        .iter()
        .all(|s| s.spec == daily_paris() && s.catchup == Catchup::All));
    let _: DueList = lossless(
        raw(&store, "scheduler_due_list", DueListParams::default()).await,
        &[],
    );
    // Ce que reçoit le moteur suffit au calcul de la prochaine échéance.
    for due_schedule in &due.schedules {
        let calendars = CalendarSet::from_calendars(&due_schedule.calendars).expect("calendriers");
        let created = to_timestamp("created_at", &due_schedule.created_at).expect("création");
        let spec = Spec::parse(&due_schedule.spec, created, calendars).expect("règles lues");
        assert!(spec.next_after(Timestamp::now()).expect("calcul").is_some());
    }

    // schedule_next_set : prochaine échéance, ou planification invalide
    let next = store
        .schedule_next_set(ScheduleNextSetParams {
            schedule: first.id.clone(),
            next_fire_at: Some(now_plus(3600)),
            invalid_reason: None,
            language: None,
        })
        .await
        .expect("prochaine");
    assert!(next.next_fire_at.is_some());
    let invalid: Schedule = lossless(
        raw(
            &store,
            "scheduler_schedule_next_set",
            ScheduleNextSetParams {
                schedule: third.id.clone(),
                next_fire_at: None,
                invalid_reason: Some("no_future_fire: spec".to_string()),
                language: None,
            },
        )
        .await,
        &[],
    );
    assert_eq!(invalid.state, ScheduleState::Invalid);

    // schedule_fire : échéances passées, prochaine échéance
    let fired = store
        .schedule_fire(ScheduleFireParams {
            schedule: first.id.clone(),
            fire_times: vec![now_plus(-120), now_plus(-60)],
            next_fire_at: Some(now_plus(3600)),
            language: None,
        })
        .await
        .expect("échéances");
    assert_eq!((fired.runs.len(), fired.ignored), (2, 0));
    let fired_raw: FireResult = lossless(
        raw(
            &store,
            "scheduler_schedule_fire",
            ScheduleFireParams {
                schedule: second.id.clone(),
                fire_times: vec![now_plus(-30)],
                next_fire_at: Some(now_plus(3600)),
                language: None,
            },
        )
        .await,
        &[],
    );
    assert_eq!(fired_raw.runs.len(), 1);

    // schedule_backfill puis backfill_fire
    let backfill = store
        .schedule_backfill(ScheduleBackfillParams {
            schedule: first.id.clone(),
            from: now_plus(-7200),
            to: now_plus(-3600),
            overlap: Some(Overlap::AllowAll),
            language: None,
        })
        .await
        .expect("rejeu");
    assert_eq!(backfill.state, BackfillState::Pending);
    let backfill_raw: Backfill = lossless(
        raw(
            &store,
            "scheduler_schedule_backfill",
            ScheduleBackfillParams {
                schedule: second.id.clone(),
                from: now_plus(-7200),
                to: now_plus(-3600),
                overlap: None,
                language: None,
            },
        )
        .await,
        &[],
    );
    let due = store
        .due_list(DueListParams::default())
        .await
        .expect("dues");
    assert_eq!(due.backfills.len(), 2);
    let replayed = store
        .backfill_fire(BackfillFireParams {
            backfill: backfill.id.clone(),
            fire_times: vec![now_plus(-5400)],
            done: Some(true),
            language: None,
        })
        .await
        .expect("rejoué");
    assert_eq!(
        (replayed.runs.len(), replayed.backfill.state),
        (1, BackfillState::Done)
    );
    let _: BackfillFireResult = lossless(
        raw(
            &store,
            "scheduler_backfill_fire",
            BackfillFireParams {
                backfill: backfill_raw.id.clone(),
                fire_times: vec![now_plus(-5000)],
                done: None,
                language: None,
            },
        )
        .await,
        &[],
    );

    // run_claim / run_heartbeat / run_complete / run_fail
    let claimed = store
        .run_claim(RunClaimParams {
            queue: "default".to_string(),
            node: "noeud-1".to_string(),
            limit: Some(2),
            language: None,
        })
        .await
        .expect("réservées");
    assert_eq!((claimed.items.len(), claimed.paused), (2, false));
    assert_eq!(
        format!("{:?}", claimed.items[0].lease),
        "LeaseToken([REDACTED])"
    );
    let more: ClaimResult = lossless(
        raw(
            &store,
            "scheduler_run_claim",
            RunClaimParams {
                queue: "default".to_string(),
                node: "noeud-2".to_string(),
                limit: None,
                language: None,
            },
        )
        .await,
        &[],
    );
    assert!(more.items.len() >= 2, "{more:?}");
    let a = &claimed.items[0];
    let beat = store
        .run_heartbeat(RunHeartbeatParams {
            run: a.id.clone(),
            lease: a.lease.clone(),
            language: None,
        })
        .await
        .expect("battement");
    assert!(!beat.cancel_requested);
    let _: Heartbeat = lossless(
        raw(
            &store,
            "scheduler_run_heartbeat",
            RunHeartbeatParams {
                run: a.id.clone(),
                lease: a.lease.clone(),
                language: None,
            },
        )
        .await,
        &[],
    );
    let done = store
        .run_complete(RunCompleteParams {
            run: a.id.clone(),
            lease: a.lease.clone(),
            result: Some(object(&[("pages", "3")])),
            language: None,
        })
        .await
        .expect("terminée");
    assert_eq!(done.state, RunState::Completed);
    expect_code(
        store
            .run_heartbeat(RunHeartbeatParams {
                run: a.id.clone(),
                lease: a.lease.clone(),
                language: None,
            })
            .await,
        "SCHEDULER_LEASE_LOST",
    );
    let b = &claimed.items[1];
    let failed = store
        .run_fail(RunFailParams {
            run: b.id.clone(),
            lease: b.lease.clone(),
            error: RunFailure {
                code: "ESSAI_PANNE".to_string(),
                message: Some("panne".to_string()),
            },
            retryable: Some(false),
            language: None,
        })
        .await
        .expect("échec");
    assert_eq!(failed.state, RunState::Dead);
    assert_eq!(
        failed
            .error
            .as_ref()
            .map(|e| (e.code.as_str(), e.retryable)),
        Some(("ESSAI_PANNE", false))
    );
    let c = &more.items[0];
    let _: Run = lossless(
        raw(
            &store,
            "scheduler_run_complete",
            RunCompleteParams {
                run: c.id.clone(),
                lease: c.lease.clone(),
                result: None,
                language: None,
            },
        )
        .await,
        &["lease"],
    );
    let d = &more.items[1];
    let retrying: Run = lossless(
        raw(
            &store,
            "scheduler_run_fail",
            RunFailParams {
                run: d.id.clone(),
                lease: d.lease.clone(),
                error: RunFailure {
                    code: "ESSAI_PANNE".to_string(),
                    message: None,
                },
                retryable: None,
                language: None,
            },
        )
        .await,
        &["lease"],
    );
    assert_eq!(retrying.state, RunState::Retrying);

    // run_rescue : un bail expiré (avancé par le test) est repris
    if let Some(e) = more.items.get(2) {
        client
            .query("UPDATE $run SET locked_until = time::now() - 1m")
            .bind(("run", e.id.clone()))
            .await
            .and_then(|r| r.check())
            .expect("bail expiré");
    }
    let rescued = store
        .run_rescue(RunRescueParams {
            limit: Some(10),
            language: None,
        })
        .await
        .expect("reprise");
    assert_eq!(rescued.rescued.len(), usize::from(more.items.len() > 2));
    let _: RescueResult = lossless(
        raw(&store, "scheduler_run_rescue", RunRescueParams::default()).await,
        &[],
    );

    // run_prune : rien d'assez ancien
    let pruned = store
        .run_prune(RunPruneParams {
            limit: Some(100),
            language: None,
        })
        .await
        .expect("élagage");
    assert_eq!(pruned.deleted, 0);
    let _: PruneResult = lossless(
        raw(&store, "scheduler_run_prune", RunPruneParams::default()).await,
        &[],
    );
}

#[test]
#[should_panic(expected = "champ perdu")]
fn lossless_check_detects_a_dropped_field() {
    let mut object = surrealdb::types::Object::new();
    object.insert("deleted", "scheduler_schedule:a".to_string());
    object.insert("extra", 1i64);
    let _: Deleted = lossless(Value::Object(object), &[]);
}
