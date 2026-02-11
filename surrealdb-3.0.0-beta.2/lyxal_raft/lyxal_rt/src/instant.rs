//! A trait for time instants.

use std::fmt::Debug;
use std::ops::Add;
use std::ops::AddAssign;
use std::ops::Sub;
use std::ops::SubAssign;
use std::panic::RefUnwindSafe;
use std::panic::UnwindSafe;
use std::time::Duration;

use crate::OptionalSend;
use crate::OptionalSync;

/// A measurement of a monotonically non-decreasing clock.
pub trait Instant:
    Add<Duration, Output = Self>
    + AddAssign<Duration>
    + Clone
    + Copy
    + Debug
    + Eq
    + Ord
    + PartialEq
    + PartialOrd
    + RefUnwindSafe
    + OptionalSend
    + Sub<Duration, Output = Self>
    + Sub<Self, Output = Duration>
    + SubAssign<Duration>
    + OptionalSync
    + Unpin
    + UnwindSafe
    + 'static
{
    /// Return the current instant.
    #[track_caller]
    fn now() -> Self;

    /// Return the amount of time since the instant.
    ///
    /// The returned duration is guaranteed to be non-negative.
    #[track_caller]
    fn elapsed(&self) -> Duration {
        let now = Self::now();
        if now > *self {
            now - *self
        } else {
            Duration::from_secs(0)
        }
    }

    /// Returns the amount of time elapsed from another instant to this one, or zero duration if
    /// that instant is later than this one.
    fn saturating_duration_since(&self, earlier: Self) -> Duration {
        if *self > earlier {
            *self - earlier
        } else {
            Duration::from_secs(0)
        }
    }

    /// Returns `Some(t)` where `t` is the time `self + duration` if there is no overflow,
    /// or `None` otherwise.
    fn checked_add(&self, duration: Duration) -> Option<Self>;

    /// Returns `Some(t)` where `t` is the time `self - duration` if there is no overflow,
    /// or `None` otherwise.
    fn checked_sub(&self, duration: Duration) -> Option<Self>;
}

impl Instant for std::time::Instant {
    fn now() -> Self {
        std::time::Instant::now()
    }

    fn checked_add(&self, duration: Duration) -> Option<Self> {
        self.checked_add(duration)
    }

    fn checked_sub(&self, duration: Duration) -> Option<Self> {
        self.checked_sub(duration)
    }
}
