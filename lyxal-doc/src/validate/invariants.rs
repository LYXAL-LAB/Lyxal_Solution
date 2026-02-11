use thiserror::Error;
use crate::core::document::Document;
use crate::core::node::{Block, Inline};

#[derive(Error, Debug, PartialEq)]
pub enum ValidationError {
    #[error("Section '{id}' must contain at least one block")]
    EmptySection { id: String },
    
    #[error("Text inline cannot be empty")]
    EmptyText,
    
    #[error("Link must have at least one inline child")]
    EmptyLink,
    
    #[error("Bold/Italic/Style container must not be empty")]
    EmptyContainer,
    
    #[error("Invalid structure: {0}")]
    InvalidStructure(String),
}

pub struct Validator;

impl Validator {
    pub fn validate_document(doc: &Document) -> Result<(), ValidationError> {
        for block in &doc.content {
            Self::validate_block(block)?;
        }
        
        Ok(())
    }

    pub fn validate_block(block: &Block) -> Result<(), ValidationError> {
        match block {
            Block::Section(s) => {
                if s.children.is_empty() {
                    return Err(ValidationError::EmptySection { id: s.id.clone() });
                }
                for child in &s.children {
                    Self::validate_block(child)?;
                }
            }
            Block::Paragraph(p) => {
                for inline in &p.inlines {
                    Self::validate_inline(inline)?;
                }
            }
            Block::Quote(q) => {
                if q.content.is_empty() {
                    return Err(ValidationError::InvalidStructure("Quote cannot be empty".to_string()));
                }
                for child in &q.content {
                    Self::validate_block(child)?;
                }
            }
            Block::List(l) => {
                if l.items.is_empty() {
                    return Err(ValidationError::InvalidStructure("List must have items".to_string()));
                }
                for item in &l.items {
                    if item.content.is_empty() {
                        return Err(ValidationError::InvalidStructure("List item cannot be empty".to_string()));
                    }
                    for b in &item.content {
                        Self::validate_block(b)?;
                    }
                }
            }
            Block::Comment(c) => {
                if c.text.is_empty() {
                    return Err(ValidationError::InvalidStructure("Comment text cannot be empty".to_string()));
                }
            }
            Block::Anchor(a) => {
                if a.name.is_empty() {
                    return Err(ValidationError::InvalidStructure("Anchor name cannot be empty".to_string()));
                }
            }
            Block::Intent(i) => {
                if i.content.is_empty() {
                    return Err(ValidationError::InvalidStructure("Intent block cannot be empty".to_string()));
                }
                for child in &i.content {
                    Self::validate_block(child)?;
                }
            }
            Block::Revision(r) => {
                if r.content.is_empty() {
                    return Err(ValidationError::InvalidStructure("Revision block cannot be empty".to_string()));
                }
                for child in &r.content {
                    Self::validate_block(child)?;
                }
            }
            Block::Iteration(it) => {
                if it.template.is_empty() {
                    return Err(ValidationError::InvalidStructure("Iteration template cannot be empty".to_string()));
                }
                for child in &it.template {
                    Self::validate_block(child)?;
                }
            }
            Block::Condition(c) => {
                if c.then_branch.is_empty() {
                    return Err(ValidationError::InvalidStructure("Condition 'then' branch cannot be empty".to_string()));
                }
                for child in &c.then_branch {
                    Self::validate_block(child)?;
                }
                if let Some(else_branch) = &c.else_branch {
                    for child in else_branch {
                        Self::validate_block(child)?;
                    }
                }
            }
            Block::Group(g) => {
                if g.children.is_empty() {
                    return Err(ValidationError::InvalidStructure("Group cannot be empty".to_string()));
                }
                for child in &g.children {
                    Self::validate_block(child)?;
                }
            }
            Block::Footnote(f) => {
                if f.content.is_empty() {
                    return Err(ValidationError::InvalidStructure("Footnote cannot be empty".to_string()));
                }
                for child in &f.content {
                    Self::validate_block(child)?;
                }
            }
            Block::Header(h) => {
                for child in &h.content {
                    Self::validate_block(child)?;
                }
            }
            Block::Footer(f) => {
                for child in &f.content {
                    Self::validate_block(child)?;
                }
            }
            _ => {}
        }
        Ok(())
    }

    pub fn validate_inline(inline: &Inline) -> Result<(), ValidationError> {
        match inline {
            Inline::Text(t) => {
                if t.text.is_empty() {
                    return Err(ValidationError::EmptyText);
                }
            }
            Inline::Bold(b) => {
                if b.content.is_empty() {
                    return Err(ValidationError::EmptyContainer);
                }
                for child in &b.content {
                    Self::validate_inline(child)?;
                }
            }
            Inline::Link(l) => {
                if l.content.is_empty() {
                    return Err(ValidationError::EmptyLink);
                }
                for child in &l.content {
                    Self::validate_inline(child)?;
                }
            }
            Inline::StyleRef(s) => {
                if s.content.is_empty() {
                    return Err(ValidationError::EmptyContainer);
                }
                for child in &s.content {
                    Self::validate_inline(child)?;
                }
            }
            Inline::Anchor(a) => {
                if a.name.is_empty() {
                    return Err(ValidationError::InvalidStructure("Anchor name cannot be empty".to_string()));
                }
            }
            Inline::Revision(r) => {
                if r.content.is_empty() {
                    return Err(ValidationError::EmptyContainer);
                }
                for child in &r.content {
                    Self::validate_inline(child)?;
                }
            }
            _ => {}
        }
        Ok(())
    }
}
