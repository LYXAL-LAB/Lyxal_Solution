use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Country {
UnitedStatesOfAmerica,
UnitedKingdom,
France,
Germany,
Canada,
Australia,
Spain,
Italy,
Japan,
China,
India,
Brazil,
Mexico,
}

impl Country {
pub fn all() -> &'static [Country] {
&[
Country::UnitedStatesOfAmerica,
Country::UnitedKingdom,
Country::France,
Country::Germany,
Country::Canada,
Country::Australia,
Country::Spain,
Country::Italy,
Country::Japan,
Country::China,
Country::India,
Country::Brazil,
Country::Mexico,
]
}

pub fn name(&self) -> &'static str {
match self {
Country::UnitedStatesOfAmerica => "United States",
Country::UnitedKingdom => "United Kingdom",
Country::France => "France",
Country::Germany => "Germany",
Country::Canada => "Canada",
Country::Australia => "Australia",
Country::Spain => "Spain",
Country::Italy => "Italy",
Country::Japan => "Japan",
Country::China => "China",
Country::India => "India",
Country::Brazil => "Brazil",
Country::Mexico => "Mexico",
}
}

pub fn alpha2(&self) -> &'static str {
match self {
Country::UnitedStatesOfAmerica => "US",
Country::UnitedKingdom => "GB",
Country::France => "FR",
Country::Germany => "DE",
Country::Canada => "CA",
Country::Australia => "AU",
Country::Spain => "ES",
Country::Italy => "IT",
Country::Japan => "JP",
Country::China => "CN",
Country::India => "IN",
Country::Brazil => "BR",
Country::Mexico => "MX",
}
}

pub fn dial_code_formatted(&self) -> &'static str {
match self {
Country::UnitedStatesOfAmerica => "+1",
Country::UnitedKingdom => "+44",
Country::France => "+33",
Country::Germany => "+49",
Country::Canada => "+1",
Country::Australia => "+61",
Country::Spain => "+34",
Country::Italy => "+39",
Country::Japan => "+81",
Country::China => "+86",
Country::India => "+91",
Country::Brazil => "+55",
Country::Mexico => "+52",
}
}

pub fn flag_emoji(&self) -> &'static str {
match self {
Country::UnitedStatesOfAmerica => "ðŸ‡ºðŸ‡¸",
Country::UnitedKingdom => "ðŸ‡¬ðŸ‡§",
Country::France => "ðŸ‡«ðŸ‡·",
Country::Germany => "ðŸ‡©ðŸ‡ª",
Country::Canada => "ðŸ‡¨ðŸ‡¦",
Country::Australia => "ðŸ‡¦ðŸ‡º",
Country::Spain => "ðŸ‡ªðŸ‡¸",
Country::Italy => "ðŸ‡®ðŸ‡¹",
Country::Japan => "ðŸ‡¯ðŸ‡µ",
Country::China => "ðŸ‡¨ðŸ‡³",
Country::India => "ðŸ‡®ðŸ‡³",
Country::Brazil => "ðŸ‡§ðŸ‡·",
Country::Mexico => "ðŸ‡²ðŸ‡½",
}
}
}
