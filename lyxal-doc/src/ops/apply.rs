use crate::core::document::Document;
use crate::core::node::{Block, Inline, ParagraphBlock, TextInline};
use crate::ops::operation::Operation;
use crate::ops::path::{Path, PathSegment};
use crate::ops::error::OperationError;
use crate::validate::Validator;

pub fn apply(doc: &Document, op: Operation) -> Result<Document, OperationError> {
    let mut new_doc = doc.clone();
    
    match op {
        Operation::InsertText { path, offset, value } => {
            apply_insert_text(&mut new_doc, path, offset, value)?;
        }
        Operation::DeleteTextRange { path, offset, length } => {
            apply_delete_text_range(&mut new_doc, path, offset, length)?;
        }
        Operation::InsertBlock { parent_path, index, block } => {
            apply_insert_block(&mut new_doc, parent_path, index, block)?;
        }
        Operation::RemoveBlock { path } => {
            apply_remove_block(&mut new_doc, path)?;
        }
        Operation::SplitParagraph { path, offset, new_block_id } => {
            apply_split_paragraph(&mut new_doc, path, offset, new_block_id)?;
        }
        Operation::UpdateBlockMeta { path, author, add_tags, remove_tag_keys, policy } => {
            apply_update_block_meta(&mut new_doc, path, author, add_tags, remove_tag_keys, policy)?;
        }
        Operation::MoveBlock { .. } | Operation::MergeParagraphs { .. } => {
            return Err(OperationError::UnsupportedOperation("Operation not yet implemented".to_string()));
        }
    }

    // Re-validation obligatoire après chaque opération
    Validator::validate_document(&new_doc)?;
    
    Ok(new_doc)
}

fn apply_insert_text(doc: &mut Document, path: Path, offset: usize, value: String) -> Result<(), OperationError> {
    let block = find_block_mut(&mut doc.content, &path)?;
    
    if let Block::Paragraph(p) = block {
        insert_into_paragraph(p, offset, value)?;
    } else {
        return Err(OperationError::UnsupportedOperation("Can only insert text into a Paragraph".to_string()));
    }
    
    Ok(())
}

fn apply_delete_text_range(doc: &mut Document, path: Path, offset: usize, length: usize) -> Result<(), OperationError> {
    let block = find_block_mut(&mut doc.content, &path)?;
    
    if let Block::Paragraph(p) = block {
        delete_from_paragraph(p, offset, length)?;
    } else {
        return Err(OperationError::UnsupportedOperation("Can only delete text from a Paragraph".to_string()));
    }
    
    Ok(())
}

fn apply_insert_block(doc: &mut Document, parent_path: Path, index: usize, block: Block) -> Result<(), OperationError> {
    if parent_path.0.is_empty() {
        if index > doc.content.len() {
            return Err(OperationError::OutOfBounds);
        }
        doc.content.insert(index, block);
    } else {
        let parent = find_block_mut(&mut doc.content, &parent_path)?;
        match parent {
            Block::Section(s) => {
                if index > s.children.len() {
                    return Err(OperationError::OutOfBounds);
                }
                s.children.insert(index, block);
            }
            _ => return Err(OperationError::UnsupportedOperation("Parent must be a Section or Document root".to_string())),
        }
    }
    Ok(())
}

fn apply_remove_block(doc: &mut Document, path: Path) -> Result<(), OperationError> {
    if path.0.len() == 1 {
        if let Some(PathSegment::Block(id)) = path.0.first() {
            let initial_len = doc.content.len();
            doc.content.retain(|b| get_block_id(b) != Some(id.clone()));
            if doc.content.len() == initial_len {
                return Err(OperationError::NodeNotFound(id.clone()));
            }
            return Ok(());
        }
    }
    Err(OperationError::UnsupportedOperation("Nested removal not yet implemented".to_string()))
}

fn apply_split_paragraph(doc: &mut Document, path: Path, offset: usize, new_block_id: String) -> Result<(), OperationError> {
    let (parent_blocks, index) = find_parent_list_mut(doc, &path)?;
    
    let new_paragraph = {
        let block = &mut parent_blocks[index];
        if let Block::Paragraph(p) = block {
            split_paragraph(p, offset, new_block_id)?
        } else {
            return Err(OperationError::UnsupportedOperation("Can only split a Paragraph".to_string()));
        }
    };
    
    parent_blocks.insert(index + 1, Block::Paragraph(new_paragraph));
    Ok(())
}

fn apply_update_block_meta(
    doc: &mut Document,
    path: Path,
    author: Option<String>,
    add_tags: Vec<crate::core::meta::SemanticTag>,
    remove_tag_keys: Vec<String>,
    policy: Option<crate::core::meta::NodePolicy>,
) -> Result<(), OperationError> {
    let block = find_block_mut(&mut doc.content, &path)?;
    let meta = get_block_meta_mut(block).ok_or_else(|| OperationError::UnsupportedOperation("Block does not have metadata".to_string()))?;

    if let Some(a) = author {
        meta.author = Some(a);
    }

    for new_tag in add_tags {
        if let Some(existing) = meta.tags.iter_mut().find(|t| t.key == new_tag.key) {
            existing.value = new_tag.value;
        } else {
            meta.tags.push(new_tag);
        }
    }

    for key in remove_tag_keys {
        meta.tags.retain(|t| t.key != key);
    }

    if let Some(p) = policy {
        meta.policy = Some(p);
    }

    Ok(())
}

// --- Helpers de navigation ---

fn find_block_mut<'a>(blocks: &'a mut Vec<Block>, path: &Path) -> Result<&'a mut Block, OperationError> {
    if path.0.is_empty() {
        return Err(OperationError::InvalidPath("Empty path".to_string()));
    }

    match &path.0[0] {
        PathSegment::Block(id) => {
            for block in blocks {
                if get_block_id(block) == Some(id.clone()) {
                    return Ok(block);
                }
                match block {
                    Block::Section(s) => {
                        if let Ok(found) = find_block_mut(&mut s.children, path) {
                            return Ok(found);
                        }
                    }
                    Block::Quote(q) => {
                        if let Ok(found) = find_block_mut(&mut q.content, path) {
                            return Ok(found);
                        }
                    }
                    Block::Group(g) => {
                        if let Ok(found) = find_block_mut(&mut g.children, path) {
                            return Ok(found);
                        }
                    }
                    Block::Intent(i) => {
                        if let Ok(found) = find_block_mut(&mut i.content, path) {
                            return Ok(found);
                        }
                    }
                    Block::Revision(r) => {
                        if let Ok(found) = find_block_mut(&mut r.content, path) {
                            return Ok(found);
                        }
                    }
                    _ => {}
                }
            }
            Err(OperationError::NodeNotFound(id.clone()))
        }
        _ => Err(OperationError::InvalidPath("First segment must be a Block ID".to_string())),
    }
}

fn find_parent_list_mut<'a>(doc: &'a mut Document, path: &Path) -> Result<(&'a mut Vec<Block>, usize), OperationError> {
    if path.0.is_empty() {
        return Err(OperationError::InvalidPath("Empty path".to_string()));
    }

    if path.0.len() == 1 {
        if let PathSegment::Block(id) = &path.0[0] {
            let index = doc.content.iter().position(|b| get_block_id(b) == Some(id.clone()))
                .ok_or_else(|| OperationError::NodeNotFound(id.clone()))?;
            return Ok((&mut doc.content, index));
        }
    }
    
    Err(OperationError::UnsupportedOperation("Nested split/merge not yet implemented".to_string()))
}

fn get_block_id(block: &Block) -> Option<String> {
    match block {
        Block::Section(s) => Some(s.id.clone()),
        Block::Paragraph(p) => Some(p.id.clone()),
        Block::List(l) => Some(l.id.clone()),
        Block::Table(t) => Some(t.id.clone()),
        Block::Image(i) => Some(i.id.clone()),
        Block::Quote(q) => Some(q.id.clone()),
        Block::CodeBlock(c) => Some(c.id.clone()),
        Block::Anchor(a) => Some(a.id.clone()),
        Block::Comment(c) => Some(c.id.clone()),
        Block::Intent(i) => Some(i.id.clone()),
        Block::SignatureSlot(s) => Some(s.id.clone()),
        Block::Revision(r) => Some(r.id.clone()),
        Block::Iteration(it) => Some(it.id.clone()),
        Block::Condition(c) => Some(c.id.clone()),
        Block::Group(g) => Some(g.id.clone()),
        Block::Footnote(f) => Some(f.id.clone()),
        Block::Header(h) => Some(h.id.clone()),
        Block::Footer(f) => Some(f.id.clone()),
        Block::Shape(s) => Some(s.id.clone()),
        Block::Divider => None,
        Block::PageBreak => None,
    }
}

fn get_block_meta_mut(block: &mut Block) -> Option<&mut crate::core::Metadata> {
    match block {
        Block::Section(s) => Some(&mut s.meta),
        Block::Paragraph(p) => Some(&mut p.meta),
        Block::List(l) => Some(&mut l.meta),
        Block::Table(t) => Some(&mut t.meta),
        Block::Image(i) => Some(&mut i.meta),
        Block::Quote(q) => Some(&mut q.meta),
        Block::CodeBlock(c) => Some(&mut c.meta),
        Block::Anchor(a) => Some(&mut a.meta),
        Block::Comment(c) => Some(&mut c.meta),
        Block::Intent(i) => Some(&mut i.meta),
        Block::SignatureSlot(s) => Some(&mut s.meta),
        Block::Revision(r) => Some(&mut r.meta),
        Block::Iteration(it) => Some(&mut it.meta),
        Block::Condition(c) => Some(&mut c.meta),
        Block::Group(g) => Some(&mut g.meta),
        Block::Footnote(f) => Some(&mut f.meta),
        Block::Header(h) => Some(&mut h.meta),
        Block::Footer(f) => Some(&mut f.meta),
        Block::Shape(s) => Some(&mut s.meta),
        Block::Divider => None,
        Block::PageBreak => None,
    }
}

fn insert_into_paragraph(p: &mut ParagraphBlock, offset: usize, value: String) -> Result<(), OperationError> {
    if p.inlines.is_empty() {
        p.inlines.push(Inline::Text(TextInline { text: value }));
        return Ok(());
    }

    let mut current_offset = 0;
    for inline in &mut p.inlines {
        if let Inline::Text(t) = inline {
            let len = t.text.len();
            if offset >= current_offset && offset <= current_offset + len {
                let local_offset = offset - current_offset;
                t.text.insert_str(local_offset, &value);
                return Ok(());
            }
            current_offset += len;
        }
    }
    Err(OperationError::OutOfBounds)
}

fn delete_from_paragraph(p: &mut ParagraphBlock, offset: usize, length: usize) -> Result<(), OperationError> {
    let mut current_offset = 0;
    let mut to_remove = Vec::new();
    
    for (i, inline) in p.inlines.iter_mut().enumerate() {
        if let Inline::Text(t) = inline {
            let len = t.text.len();
            if offset >= current_offset && offset + length <= current_offset + len {
                let local_offset = offset - current_offset;
                t.text.drain(local_offset..local_offset + length);
                if t.text.is_empty() {
                    to_remove.push(i);
                }
                break;
            }
            current_offset += len;
        }
    }
    
    for i in to_remove.into_iter().rev() {
        p.inlines.remove(i);
    }
    Ok(())
}

fn split_paragraph(p: &mut ParagraphBlock, offset: usize, new_id: String) -> Result<ParagraphBlock, OperationError> {
    let mut current_offset = 0;
    let mut split_index = None;
    let mut split_inline_offset = None;
    
    for (i, inline) in p.inlines.iter().enumerate() {
        if let Inline::Text(t) = inline {
            let len = t.text.len();
            if offset >= current_offset && offset <= current_offset + len {
                split_index = Some(i);
                split_inline_offset = Some(offset - current_offset);
                break;
            }
            current_offset += len;
        }
    }
    
    let (split_idx, inline_off) = split_index.zip(split_inline_offset).ok_or(OperationError::OutOfBounds)?;
    let mut new_inlines = Vec::new();
    
    if let Inline::Text(t) = &mut p.inlines[split_idx] {
        let remaining_text = t.text.drain(inline_off..).collect::<String>();
        if !remaining_text.is_empty() {
            new_inlines.push(Inline::Text(TextInline { text: remaining_text }));
        }
    }
    
    new_inlines.extend(p.inlines.drain(split_idx + 1 ..));
    
    Ok(ParagraphBlock {
        id: new_id,
        meta: p.meta.clone(),
        inlines: new_inlines,
    })
}
