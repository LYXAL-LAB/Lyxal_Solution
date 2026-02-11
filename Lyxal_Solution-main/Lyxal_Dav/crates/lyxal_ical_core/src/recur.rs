use crate::timezone::{TimeSpec, VTimezoneDef, local_to_utc_with_tzid, parse_naive_or_utc};
use crate::IcalError;
use chrono::{Datelike, Duration, NaiveDateTime, TimeZone, Timelike, Utc};
use chrono_tz::Tz;
use std::collections::HashSet;

#[derive(Debug)]
struct RRule {
    freq: Freq,
    interval: i64,
    count: Option<usize>,
    until: Option<chrono::DateTime<Utc>>,
    byday: Vec<ByDay>,
    bymonth: Vec<u32>,
    bymonthday: Vec<i32>,
    wkst: chrono::Weekday,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Freq {
    Daily,
    Weekly,
    Monthly,
    Yearly,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
struct ByDay {
    ordinal: Option<i32>,
    weekday: chrono::Weekday,
}

fn parse_weekday(s: &str) -> Option<chrono::Weekday> {
    match s {
        "MO" => Some(chrono::Weekday::Mon),
        "TU" => Some(chrono::Weekday::Tue),
        "WE" => Some(chrono::Weekday::Wed),
        "TH" => Some(chrono::Weekday::Thu),
        "FR" => Some(chrono::Weekday::Fri),
        "SA" => Some(chrono::Weekday::Sat),
        "SU" => Some(chrono::Weekday::Sun),
        _ => None,
    }
}

fn parse_rrule(rrule: &str, tz: Option<Tz>) -> Result<RRule, IcalError> {
    let mut rule = RRule {
        freq: Freq::Daily,
        interval: 1,
        count: None,
        until: None,
        byday: Vec::new(),
        bymonth: Vec::new(),
        bymonthday: Vec::new(),
        wkst: chrono::Weekday::Mon,
    };

    for part in rrule.split(';') {
        let mut kv = part.splitn(2, '=');
        let k = kv.next().unwrap_or("").to_ascii_uppercase();
        let v = kv.next().unwrap_or("");
        match k.as_str() {
            "FREQ" => {
                rule.freq = match v {
                    "DAILY" => Freq::Daily,
                    "WEEKLY" => Freq::Weekly,
                    "MONTHLY" => Freq::Monthly,
                    "YEARLY" => Freq::Yearly,
                    _ => return Err(IcalError::ParseError { line: 0, reason: format!("Unsupported FREQ {}", v) }),
                }
            }
            "INTERVAL" => {
                rule.interval = v.parse::<i64>().map_err(|_| IcalError::ParseError { line: 0, reason: "Bad INTERVAL".into() })?;
                if rule.interval <= 0 {
                    rule.interval = 1;
                }
            }
            "COUNT" => {
                rule.count = Some(v.parse::<usize>().map_err(|_| IcalError::ParseError { line: 0, reason: "Bad COUNT".into() })?);
            }
            "UNTIL" => {
                rule.until = Some(parse_datetime_utc(v, tz)?);
            }
            "BYDAY" => {
                for item in v.split(',') {
                    let (ord, wd_str) = if let Some(pos) = item.find(|c: char| c.is_alphabetic()) {
                        let (o, w) = item.split_at(pos);
                        (o, w)
                    } else {
                        ("", item)
                    };
                    let weekday = parse_weekday(wd_str).ok_or_else(|| IcalError::ParseError { line: 0, reason: "Bad BYDAY".into() })?;
                    let ordinal = if ord.is_empty() { None } else { ord.parse::<i32>().ok() };
                    rule.byday.push(ByDay { ordinal, weekday });
                }
            }
            "BYMONTH" => {
                for m in v.split(',') {
                    let mm = m.parse::<u32>().map_err(|_| IcalError::ParseError { line: 0, reason: "Bad BYMONTH".into() })?;
                    if (1..=12).contains(&mm) {
                        rule.bymonth.push(mm);
                    }
                }
            }
            "BYMONTHDAY" => {
                for d in v.split(',') {
                    let dd = d.parse::<i32>().map_err(|_| IcalError::ParseError { line: 0, reason: "Bad BYMONTHDAY".into() })?;
                    if (-31..=31).contains(&dd) && dd != 0 {
                        rule.bymonthday.push(dd);
                    }
                }
            }
            "WKST" => {
                if let Some(wd) = parse_weekday(&v.to_ascii_uppercase()) {
                    rule.wkst = wd;
                }
            }
            _ => {}
        }
    }

    Ok(rule)
}

fn parse_datetime_utc(s: &str, tz: Option<Tz>) -> Result<chrono::DateTime<Utc>, IcalError> {
    if let Ok(dt) = chrono::DateTime::parse_from_rfc3339(s) {
        return Ok(dt.with_timezone(&Utc));
    }
    if s.ends_with('Z') {
        if let Ok(ndt) = chrono::NaiveDateTime::parse_from_str(&s[..s.len() - 1], "%Y%m%dT%H%M%S") {
            return Ok(chrono::DateTime::<Utc>::from_naive_utc_and_offset(ndt, Utc));
        }
    }
    if let Some(tzid) = tz {
        if let Ok(ndt) = chrono::NaiveDateTime::parse_from_str(s, "%Y%m%dT%H%M%S") {
            if let Some(loc) = tzid.from_local_datetime(&ndt).single() {
                return Ok(loc.with_timezone(&Utc));
            }
        }
    }
    Err(IcalError::ParseError { line: 0, reason: format!("Invalid datetime {}", s) })
}

#[derive(Clone)]
enum ParsedTime {
    Utc(chrono::DateTime<Utc>),
    Floating(chrono::NaiveDateTime),
}

fn parse_with_spec(
    s: &str,
    tzid_param: Option<&str>,
    vtz: &std::collections::HashMap<String, VTimezoneDef>,
) -> Result<(ParsedTime, TimeSpec, bool), IcalError> {
    let (naive, had_z) = parse_naive_or_utc(s)?;
    if had_z {
        return Ok((ParsedTime::Utc(chrono::DateTime::<Utc>::from_naive_utc_and_offset(naive, Utc)), TimeSpec::Utc, true));
    }
    if let Some(tzid) = tzid_param {
        if !vtz.is_empty() {
            if let Ok(dt) = local_to_utc_with_tzid(tzid, &naive, vtz) {
                return Ok((ParsedTime::Utc(dt), TimeSpec::LocalTz(tzid.to_string()), false));
            }
        }
        if let Ok(tz) = tzid.parse::<Tz>() {
            if let Some(loc) = tz.from_local_datetime(&naive).single() {
                return Ok((ParsedTime::Utc(loc.with_timezone(&Utc)), TimeSpec::LocalTz(tzid.to_string()), false));
            }
        }
        return Err(IcalError::ParseError { line: 0, reason: format!("Unknown TZID {}", tzid) });
    }
    Ok((ParsedTime::Floating(naive), TimeSpec::Floating, false))
}

pub fn occurrences(
    rrule: &str,
    dtstart: &str,
    tz: Option<&str>,
    range_start: &str,
    range_end: &str,
    exdates: &[&str],
    rdates: &[&str],
) -> Result<Vec<String>, IcalError> {
    let empty = std::collections::HashMap::new();
    occurrences_with_vtimezones(rrule, dtstart, tz, range_start, range_end, exdates, rdates, &empty)
}

pub fn occurrences_with_vtimezones(
    rrule: &str,
    dtstart: &str,
    tz: Option<&str>,
    range_start: &str,
    range_end: &str,
    exdates: &[&str],
    rdates: &[&str],
    vtimezones: &std::collections::HashMap<String, VTimezoneDef>,
) -> Result<Vec<String>, IcalError> {
    let tz_parsed = tz.and_then(|s| s.parse::<Tz>().ok());
    let rule = parse_rrule(rrule, tz_parsed)?;

    let (dtstart_parsed, spec, had_z_dtstart) = parse_with_spec(dtstart, tz, vtimezones)?;
    let (range_start_p, spec_start, _) = parse_with_spec(range_start, tz, vtimezones)?;
    let (range_end_p, _, _) = parse_with_spec(range_end, tz, vtimezones)?;

    let is_floating = matches!(spec, TimeSpec::Floating) || matches!(spec_start, TimeSpec::Floating);

    if is_floating {
        let dtstart_naive = match dtstart_parsed {
            ParsedTime::Floating(n) => n,
            ParsedTime::Utc(u) => u.naive_utc(),
        };
        let window_start = match range_start_p {
            ParsedTime::Floating(n) => n,
            ParsedTime::Utc(u) => u.naive_utc(),
        };
        let window_end = match range_end_p {
            ParsedTime::Floating(n) => n,
            ParsedTime::Utc(u) => u.naive_utc(),
        };
        let ex_set: HashSet<NaiveDateTime> = exdates.iter().map(|s| parse_naive_or_utc(s).map(|(n, _)| n).unwrap()).collect();
        let mut r_set: HashSet<NaiveDateTime> = rdates
            .iter()
            .map(|s| parse_naive_or_utc(s).map(|(n, _)| n).unwrap())
            .filter(|d| *d >= window_start && *d <= window_end)
            .collect();

        let conv = |dt: &NaiveDateTime| Ok(chrono::DateTime::<Utc>::from_naive_utc_and_offset(*dt, Utc));
        let mut out = Vec::new();
        match rule.freq {
            Freq::Daily => gen_daily_naive(&rule, dtstart_naive, window_start, window_end, &ex_set, &mut out, &conv)?,
            Freq::Weekly => gen_weekly_naive(&rule, dtstart_naive, window_start, window_end, &ex_set, &mut out, &conv)?,
            Freq::Monthly => gen_monthly_naive(&rule, dtstart_naive, window_start, window_end, &ex_set, &mut out, &conv)?,
            Freq::Yearly => gen_yearly_naive(&rule, dtstart_naive, window_start, window_end, &ex_set, &mut out, &conv)?,
        }
        out.extend(r_set.drain());
        out.sort();
        out.dedup();
        let out: Vec<String> = out
            .into_iter()
            .filter(|d| *d >= window_start && *d <= window_end)
            .filter(|d| !ex_set.contains(d))
            .map(|d| d.format("%Y-%m-%dT%H:%M:%S").to_string())
            .collect();
        return Ok(out);
    }

    // Local TZ branch (non-floating, non-UTC input)
    if let TimeSpec::LocalTz(tzid_str) = &spec {
        if !had_z_dtstart {
            let dtstart_naive = parse_naive_or_utc(dtstart)?.0;
            let window_start_utc = match range_start_p {
                ParsedTime::Utc(u) => u,
                ParsedTime::Floating(n) => chrono::DateTime::<Utc>::from_naive_utc_and_offset(n, Utc),
            };
            let window_end_utc = match range_end_p {
                ParsedTime::Utc(u) => u,
                ParsedTime::Floating(n) => chrono::DateTime::<Utc>::from_naive_utc_and_offset(n, Utc),
            };

            let ex_set: HashSet<NaiveDateTime> = exdates.iter().map(|s| parse_naive_or_utc(s).map(|(n, _)| n).unwrap()).collect();
            let mut r_set: HashSet<NaiveDateTime> = rdates.iter().map(|s| parse_naive_or_utc(s).map(|(n, _)| n).unwrap()).collect();

            let tzid_owned = tzid_str.clone();
            let conv_local = |dt: &NaiveDateTime| local_to_utc_with_tzid(&tzid_owned, dt, vtimezones);

            let mut out_local = Vec::new();
            let min_dt = chrono::NaiveDateTime::MIN;
            let max_dt = chrono::NaiveDateTime::MAX;
            match rule.freq {
                Freq::Daily => gen_daily_naive(&rule, dtstart_naive, min_dt, max_dt, &ex_set, &mut out_local, &conv_local)?,
                Freq::Weekly => gen_weekly_naive(&rule, dtstart_naive, min_dt, max_dt, &ex_set, &mut out_local, &conv_local)?,
                Freq::Monthly => gen_monthly_naive(&rule, dtstart_naive, min_dt, max_dt, &ex_set, &mut out_local, &conv_local)?,
                Freq::Yearly => gen_yearly_naive(&rule, dtstart_naive, min_dt, max_dt, &ex_set, &mut out_local, &conv_local)?,
            }
            out_local.extend(r_set.drain());
            out_local.sort();
            out_local.dedup();

            let mut out_utc = Vec::new();
            for dt in out_local {
                if ex_set.contains(&dt) {
                    continue;
                }
                let as_utc = conv_local(&dt)?;
                if as_utc >= window_start_utc && as_utc <= window_end_utc {
                    out_utc.push(as_utc);
                }
            }
            out_utc.sort();
            out_utc.dedup();
            let res: Vec<String> = out_utc.into_iter().map(|d| d.to_rfc3339()).collect();
            return Ok(res);
        }
    }

    let dtstart_utc = match dtstart_parsed {
        ParsedTime::Utc(u) => u,
        ParsedTime::Floating(n) => chrono::DateTime::<Utc>::from_naive_utc_and_offset(n, Utc),
    };
    let window_start = match range_start_p {
        ParsedTime::Utc(u) => u,
        ParsedTime::Floating(n) => chrono::DateTime::<Utc>::from_naive_utc_and_offset(n, Utc),
    };
    let window_end = match range_end_p {
        ParsedTime::Utc(u) => u,
        ParsedTime::Floating(n) => chrono::DateTime::<Utc>::from_naive_utc_and_offset(n, Utc),
    };

    let mut ex_set = HashSet::new();
    for e in exdates {
        ex_set.insert(parse_with_spec(e, tz, vtimezones).map(|(p, _, _)| match p {
            ParsedTime::Utc(u) => u,
            ParsedTime::Floating(n) => chrono::DateTime::<Utc>::from_naive_utc_and_offset(n, Utc),
        })?);
    }
    let mut r_set = HashSet::new();
    for r in rdates {
        let dt = parse_with_spec(r, tz, vtimezones).map(|(p, _, _)| match p {
            ParsedTime::Utc(u) => u,
            ParsedTime::Floating(n) => chrono::DateTime::<Utc>::from_naive_utc_and_offset(n, Utc),
        })?;
        if dt >= window_start && dt <= window_end {
            r_set.insert(dt);
        }
    }

    let mut out = Vec::new();
    match rule.freq {
        Freq::Daily => generate_daily(&rule, dtstart_utc, window_start, window_end, &ex_set, &mut out)?,
        Freq::Weekly => generate_weekly(&rule, dtstart_utc, window_start, window_end, &ex_set, &mut out)?,
        Freq::Monthly => generate_monthly(&rule, dtstart_utc, window_start, window_end, &ex_set, &mut out)?,
        Freq::Yearly => generate_yearly(&rule, dtstart_utc, window_start, window_end, &ex_set, &mut out)?,
    }

    out.extend(r_set.into_iter());
    out.sort();
    out.dedup();
    let filtered: Vec<String> = out
        .into_iter()
        .filter(|dt| *dt >= window_start && *dt <= window_end)
        .filter(|dt| !ex_set.contains(dt))
        .map(|dt| dt.to_rfc3339())
        .collect();
    Ok(filtered)
}

fn check_until(rule: &RRule, dt: chrono::DateTime<Utc>) -> bool {
    if let Some(until) = rule.until {
        dt <= until
    } else {
        true
    }
}

fn generate_daily(
    rule: &RRule,
    start: chrono::DateTime<Utc>,
    window_start: chrono::DateTime<Utc>,
    window_end: chrono::DateTime<Utc>,
    ex: &HashSet<chrono::DateTime<Utc>>,
    out: &mut Vec<chrono::DateTime<Utc>>,
) -> Result<(), IcalError> {
    let mut current = start;
    let mut delivered = 0usize;
    while current <= window_end {
        if !check_until(rule, current) {
            break;
        }
        if current >= window_start && !ex.contains(&current) {
            out.push(current);
            delivered += 1;
            if let Some(c) = rule.count {
                if delivered >= c {
                    break;
                }
            }
        }
        current = current + Duration::days(rule.interval);
    }
    Ok(())
}

fn days_between(start: chrono::Weekday, target: chrono::Weekday) -> i64 {
    let s = start.num_days_from_monday() as i64;
    let t = target.num_days_from_monday() as i64;
    (t + 7 - s) % 7
}

fn prev_weekday(w: chrono::Weekday) -> chrono::Weekday {
    match w {
        chrono::Weekday::Mon => chrono::Weekday::Sun,
        chrono::Weekday::Tue => chrono::Weekday::Mon,
        chrono::Weekday::Wed => chrono::Weekday::Tue,
        chrono::Weekday::Thu => chrono::Weekday::Wed,
        chrono::Weekday::Fri => chrono::Weekday::Thu,
        chrono::Weekday::Sat => chrono::Weekday::Fri,
        chrono::Weekday::Sun => chrono::Weekday::Sat,
    }
}

fn align_week_start(dt: chrono::DateTime<Utc>, wkst: chrono::Weekday) -> chrono::DateTime<Utc> {
    let mut days = 0i64;
    let mut cur = dt.weekday();
    while cur != wkst {
        cur = prev_weekday(cur);
        days += 1;
    }
    dt - Duration::days(days)
}

fn generate_weekly(
    rule: &RRule,
    start: chrono::DateTime<Utc>,
    window_start: chrono::DateTime<Utc>,
    window_end: chrono::DateTime<Utc>,
    ex: &HashSet<chrono::DateTime<Utc>>,
    out: &mut Vec<chrono::DateTime<Utc>>,
) -> Result<(), IcalError> {
    let mut current_week_start = align_week_start(start, rule.wkst);
    let time_part = start.time();
    let bydays = if rule.byday.is_empty() {
        vec![ByDay { ordinal: None, weekday: start.weekday() }]
    } else {
        rule.byday.clone()
    };
    let mut delivered = 0usize;
    while current_week_start <= window_end {
        if !check_until(rule, current_week_start) {
            break;
        }
        for bd in &bydays {
            let dt = current_week_start + Duration::days(days_between(rule.wkst, bd.weekday) as i64);
            let dt = dt
                .with_hour(time_part.hour())
                .and_then(|d| d.with_minute(time_part.minute()))
                .and_then(|d| d.with_second(time_part.second()))
                .map(|d| d.with_nanosecond(time_part.nanosecond()).unwrap())
                .unwrap();
            if dt < start || dt > window_end {
                continue;
            }
            if !check_until(rule, dt) {
                continue;
            }
            if dt >= window_start && !ex.contains(&dt) {
                out.push(dt);
                delivered += 1;
                if let Some(c) = rule.count {
                    if delivered >= c {
                        return Ok(());
                    }
                }
            }
        }
        current_week_start = current_week_start + Duration::weeks(rule.interval);
    }
    Ok(())
}

fn generate_monthly(
    rule: &RRule,
    start: chrono::DateTime<Utc>,
    window_start: chrono::DateTime<Utc>,
    window_end: chrono::DateTime<Utc>,
    ex: &HashSet<chrono::DateTime<Utc>>,
    out: &mut Vec<chrono::DateTime<Utc>>,
) -> Result<(), IcalError> {
    let mut year = start.year();
    let mut month = start.month() as i32;
    let time_part = start.time();
    let mut delivered = 0usize;

    while chrono::NaiveDate::from_ymd_opt(year, month as u32, 1).is_some() {
        let base_date = chrono::NaiveDate::from_ymd_opt(year, month as u32, 1).unwrap();
        let base_dt = base_date.and_hms_opt(time_part.hour(), time_part.minute(), time_part.second()).unwrap().and_local_timezone(Utc).unwrap();
        if !check_until(rule, base_dt) {
            break;
        }

        let mut days = Vec::new();
        if !rule.bymonthday.is_empty() {
            for d in &rule.bymonthday {
                let day = if *d > 0 { *d as u32 } else {
                    let last = last_day_of_month(year, month as u32);
                    (last as i32 + *d + 1) as u32
                };
                if let Some(nd) = chrono::NaiveDate::from_ymd_opt(year, month as u32, day) {
                    days.push(nd);
                }
            }
        } else if !rule.byday.is_empty() {
            for bd in &rule.byday {
                if let Some(nd) = nth_weekday_of_month(year, month as u32, bd.weekday, bd.ordinal) {
                    days.push(nd);
                }
            }
        } else {
            let day = start.day();
            if let Some(nd) = chrono::NaiveDate::from_ymd_opt(year, month as u32, day) {
                days.push(nd);
            }
        }

        for d in days {
            let dt = d.and_hms_opt(time_part.hour(), time_part.minute(), time_part.second()).unwrap().and_local_timezone(Utc).unwrap();
            if dt < start || dt > window_end {
                continue;
            }
            if !check_until(rule, dt) {
                continue;
            }
            if dt >= window_start && !ex.contains(&dt) {
                out.push(dt);
                delivered += 1;
                if let Some(c) = rule.count {
                    if delivered >= c {
                        return Ok(());
                    }
                }
            }
        }

        month += rule.interval as i32;
        while month > 12 {
            month -= 12;
            year += 1;
        }
    }
    Ok(())
}

fn generate_yearly(
    rule: &RRule,
    start: chrono::DateTime<Utc>,
    window_start: chrono::DateTime<Utc>,
    window_end: chrono::DateTime<Utc>,
    ex: &HashSet<chrono::DateTime<Utc>>,
    out: &mut Vec<chrono::DateTime<Utc>>,
) -> Result<(), IcalError> {
    let mut year = start.year();
    let time_part = start.time();
    let months = if rule.bymonth.is_empty() {
        vec![start.month()]
    } else {
        rule.bymonth.clone()
    };
    let mut delivered = 0usize;

    loop {
        let candidate = chrono::NaiveDate::from_ymd_opt(year, 1, 1).unwrap().and_hms_opt(0, 0, 0).unwrap().and_local_timezone(Utc).unwrap();
        if !check_until(rule, candidate) {
            break;
        }

        for m in &months {
            let mut days = Vec::new();
            if !rule.bymonthday.is_empty() {
                for d in &rule.bymonthday {
                    let day = if *d > 0 { *d as u32 } else {
                        let last = last_day_of_month(year, *m);
                        (last as i32 + *d + 1) as u32
                    };
                    if let Some(nd) = chrono::NaiveDate::from_ymd_opt(year, *m, day) {
                        days.push(nd);
                    }
                }
            } else if !rule.byday.is_empty() {
                for bd in &rule.byday {
                    if let Some(nd) = nth_weekday_of_month(year, *m, bd.weekday, bd.ordinal) {
                        days.push(nd);
                    }
                }
            } else {
                let day = start.day();
                if let Some(nd) = chrono::NaiveDate::from_ymd_opt(year, *m, day) {
                    days.push(nd);
                }
            }

            for d in days {
                let dt = d.and_hms_opt(time_part.hour(), time_part.minute(), time_part.second()).unwrap().and_local_timezone(Utc).unwrap();
                if dt < start || dt > window_end {
                    continue;
                }
                if !check_until(rule, dt) {
                    continue;
                }
                if dt >= window_start && !ex.contains(&dt) {
                    out.push(dt);
                    delivered += 1;
                    if let Some(c) = rule.count {
                        if delivered >= c {
                            return Ok(());
                        }
                    }
                }
            }
        }
        year += rule.interval as i32;
    }
    Ok(())
}

fn nth_weekday_of_month(year: i32, month: u32, weekday: chrono::Weekday, ordinal: Option<i32>) -> Option<chrono::NaiveDate> {
    let first = chrono::NaiveDate::from_ymd_opt(year, month, 1)?;
    let mut day = first;
    let mut count = 0;
    while day.month() == month {
        if day.weekday() == weekday {
            count += 1;
            if ordinal == Some(count) || (ordinal.is_none() && count == 1) {
                return Some(day);
            }
        }
        day = day.succ_opt()?;
    }
    if let Some(ord) = ordinal {
        if ord < 0 {
            let mut day = day.pred_opt()?;
            count = 0;
            while day.month() == month {
                if day.weekday() == weekday {
                    count -= 1;
                    if count == ord {
                        return Some(day);
                    }
                }
                day = day.pred_opt()?;
            }
        }
    }
    None
}

fn last_day_of_month(year: i32, month: u32) -> u32 {
    let mut day = 31;
    while chrono::NaiveDate::from_ymd_opt(year, month, day).is_none() {
        day -= 1;
    }
    day
}

fn gen_daily_naive(
    rule: &RRule,
    start: NaiveDateTime,
    window_start: NaiveDateTime,
    window_end: NaiveDateTime,
    ex: &HashSet<NaiveDateTime>,
    out: &mut Vec<NaiveDateTime>,
    to_utc: &dyn Fn(&NaiveDateTime) -> Result<chrono::DateTime<Utc>, IcalError>,
) -> Result<(), IcalError> {
    let mut current = start;
    let mut delivered = 0usize;
    while current <= window_end {
        if let Some(until) = rule.until {
            if to_utc(&current)? > until {
                break;
            }
        }
        if current >= window_start && !ex.contains(&current) {
            out.push(current);
            delivered += 1;
            if let Some(c) = rule.count {
                if delivered >= c {
                    break;
                }
            }
        }
        current = current + Duration::days(rule.interval);
    }
    Ok(())
}

fn gen_weekly_naive(
    rule: &RRule,
    start: NaiveDateTime,
    window_start: NaiveDateTime,
    window_end: NaiveDateTime,
    ex: &HashSet<NaiveDateTime>,
    out: &mut Vec<NaiveDateTime>,
    to_utc: &dyn Fn(&NaiveDateTime) -> Result<chrono::DateTime<Utc>, IcalError>,
) -> Result<(), IcalError> {
    let mut current_week_start = align_week_start_dt(start, rule.wkst);
    let time_part = start.time();
    let bydays = if rule.byday.is_empty() {
        vec![ByDay { ordinal: None, weekday: weekday_naive(start) }]
    } else {
        rule.byday.clone()
    };
    let mut delivered = 0usize;
    while current_week_start <= window_end {
        if let Some(until) = rule.until {
            if chrono::DateTime::<Utc>::from_naive_utc_and_offset(current_week_start, Utc) > until {
                break;
            }
        }
        for bd in &bydays {
            let dt = current_week_start + Duration::days(days_between(rule.wkst, bd.weekday) as i64);
            let dt = dt
                .with_hour(time_part.hour())
                .and_then(|d| d.with_minute(time_part.minute()))
                .and_then(|d| d.with_second(time_part.second()))
                .map(|d| d.with_nanosecond(time_part.nanosecond()).unwrap())
                .unwrap();
            if dt < start || dt > window_end {
                continue;
            }
            if let Some(until) = rule.until {
                if to_utc(&dt)? > until {
                    continue;
                }
            }
            if dt >= window_start && !ex.contains(&dt) {
                out.push(dt);
                delivered += 1;
                if let Some(c) = rule.count {
                    if delivered >= c {
                        return Ok(());
                    }
                }
            }
        }
        current_week_start = current_week_start + Duration::weeks(rule.interval);
    }
    Ok(())
}

fn gen_monthly_naive(
    rule: &RRule,
    start: NaiveDateTime,
    window_start: NaiveDateTime,
    window_end: NaiveDateTime,
    ex: &HashSet<NaiveDateTime>,
    out: &mut Vec<NaiveDateTime>,
    to_utc: &dyn Fn(&NaiveDateTime) -> Result<chrono::DateTime<Utc>, IcalError>,
) -> Result<(), IcalError> {
    let mut year = start.date().year();
    let mut month = start.date().month() as i32;
    let time_part = start.time();
    let mut delivered = 0usize;

    while chrono::NaiveDate::from_ymd_opt(year, month as u32, 1).is_some() {
        let base_date = chrono::NaiveDate::from_ymd_opt(year, month as u32, 1).unwrap();
        if let Some(until) = rule.until {
            if to_utc(&base_date.and_hms_opt(0, 0, 0).unwrap())? > until {
                break;
            }
        }

        let mut days = Vec::new();
        if !rule.bymonthday.is_empty() {
            for d in &rule.bymonthday {
                let day = if *d > 0 { *d as u32 } else {
                    let last = last_day_of_month(year, month as u32);
                    (last as i32 + *d + 1) as u32
                };
                if let Some(nd) = chrono::NaiveDate::from_ymd_opt(year, month as u32, day) {
                    days.push(nd);
                }
            }
        } else if !rule.byday.is_empty() {
            for bd in &rule.byday {
                if let Some(nd) = nth_weekday_of_month(year, month as u32, bd.weekday, bd.ordinal) {
                    days.push(nd);
                }
            }
        } else {
            let day = start.date().day();
            if let Some(nd) = chrono::NaiveDate::from_ymd_opt(year, month as u32, day) {
                days.push(nd);
            }
        }

        for d in days {
            let dt = d.and_time(time_part);
            if dt < start || dt > window_end {
                continue;
            }
            if let Some(until) = rule.until {
                if to_utc(&dt)? > until {
                    continue;
                }
            }
            if dt >= window_start && !ex.contains(&dt) {
                out.push(dt);
                delivered += 1;
                if let Some(c) = rule.count {
                    if delivered >= c {
                        return Ok(());
                    }
                }
            }
        }

        month += rule.interval as i32;
        while month > 12 {
            month -= 12;
            year += 1;
        }
    }
    Ok(())
}

fn gen_yearly_naive(
    rule: &RRule,
    start: NaiveDateTime,
    window_start: NaiveDateTime,
    window_end: NaiveDateTime,
    ex: &HashSet<NaiveDateTime>,
    out: &mut Vec<NaiveDateTime>,
    to_utc: &dyn Fn(&NaiveDateTime) -> Result<chrono::DateTime<Utc>, IcalError>,
) -> Result<(), IcalError> {
    let mut year = start.date().year();
    let time_part = start.time();
    let months = if rule.bymonth.is_empty() {
        vec![start.date().month()]
    } else {
        rule.bymonth.clone()
    };
    let mut delivered = 0usize;

    loop {
        if let Some(until) = rule.until {
            let candidate = chrono::NaiveDate::from_ymd_opt(year, 1, 1).unwrap().and_hms_opt(0, 0, 0).unwrap();
            if to_utc(&candidate)? > until {
                break;
            }
        }

        for m in &months {
            let mut days = Vec::new();
            if !rule.bymonthday.is_empty() {
                for d in &rule.bymonthday {
                    let day = if *d > 0 { *d as u32 } else {
                        let last = last_day_of_month(year, *m);
                        (last as i32 + *d + 1) as u32
                    };
                    if let Some(nd) = chrono::NaiveDate::from_ymd_opt(year, *m, day) {
                        days.push(nd);
                    }
                }
            } else if !rule.byday.is_empty() {
                for bd in &rule.byday {
                    if let Some(nd) = nth_weekday_of_month(year, *m, bd.weekday, bd.ordinal) {
                        days.push(nd);
                    }
                }
            } else {
                let day = start.date().day();
                if let Some(nd) = chrono::NaiveDate::from_ymd_opt(year, *m, day) {
                    days.push(nd);
                }
            }

            for d in days {
                let dt = d.and_time(time_part);
                if dt < start || dt > window_end {
                    continue;
                }
                if let Some(until) = rule.until {
                    if chrono::DateTime::<Utc>::from_naive_utc_and_offset(dt, Utc) > until {
                        continue;
                    }
                }
                if dt >= window_start && !ex.contains(&dt) {
                    out.push(dt);
                    delivered += 1;
                    if let Some(c) = rule.count {
                        if delivered >= c {
                            return Ok(());
                        }
                    }
                }
            }
        }
        year += rule.interval as i32;
    }
    Ok(())
}

fn weekday_naive(dt: NaiveDateTime) -> chrono::Weekday {
    dt.date().weekday()
}

fn align_week_start_dt(dt: NaiveDateTime, wkst: chrono::Weekday) -> NaiveDateTime {
    let mut days = 0i64;
    let mut cur = dt.date().weekday();
    while cur != wkst {
        cur = prev_weekday(cur);
        days += 1;
    }
    dt - Duration::days(days)
}
