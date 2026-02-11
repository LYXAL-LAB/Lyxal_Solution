use std::collections::HashMap;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct IcalObject {
    pub calendars: Vec<VCalendar>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct VCalendar {
    pub props: Vec<Property>,
    pub components: Vec<Component>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Component {
    VEvent { props: Vec<Property>, subcomponents: Vec<Component> },
    VTodo { props: Vec<Property>, subcomponents: Vec<Component> },
    VJournal { props: Vec<Property>, subcomponents: Vec<Component> },
    VFreebusy { props: Vec<Property>, subcomponents: Vec<Component> },
    VTimezone { props: Vec<Property>, subcomponents: Vec<Component> },
    Other { name: String, props: Vec<Property>, subcomponents: Vec<Component> },
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Property {
    pub name: String,
    pub params: HashMap<String, Vec<String>>,
    pub value: String,
}

impl IcalObject {
    pub fn new(calendars: Vec<VCalendar>) -> Self {
        Self { calendars }
    }
}

impl VCalendar {
    pub fn new(props: Vec<Property>, components: Vec<Component>) -> Self {
        Self { props, components }
    }
}

