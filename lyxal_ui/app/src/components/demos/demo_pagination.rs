use leptos::prelude::*;

use crate::components::ui::pagination::{
PageDirection, Pagination, PaginationItem, PaginationLink, PaginationList, PaginationNavButton,
};

#[component]
pub fn DemoPagination() -> impl IntoView {
view! {
<Pagination>
<PaginationList>
<PaginationItem>
<PaginationNavButton direction=PageDirection::Previous />
</PaginationItem>
<PaginationItem>
<PaginationLink page=1u32 />
</PaginationItem>
<PaginationItem>
<PaginationLink page=2u32 />
</PaginationItem>
<PaginationItem>
<PaginationLink page=3u32 />
</PaginationItem>
<PaginationItem>
<PaginationLink page=4u32 />
</PaginationItem>
<PaginationItem>
<PaginationLink page=5u32 />
</PaginationItem>
<PaginationItem>
<PaginationNavButton direction=PageDirection::Next />
</PaginationItem>
</PaginationList>
</Pagination>
}
}
