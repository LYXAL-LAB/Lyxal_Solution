use serde::{Deserialize, Serialize};

/// Identifiant unique pour tout noeud (Block ou Inline)
pub type NodeId = String;

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum Block {
    Section(SectionBlock),
    Paragraph(ParagraphBlock),
    List(ListBlock),
    Table(TableBlock),
    Image(ImageBlock),
    Quote(QuoteBlock),
    CodeBlock(CodeBlockBlock),
    Divider,
    /// Un point d'ancrage nommé pour les références
    Anchor(AnchorNode),
    /// Un bloc de commentaire rattaché à un autre élément
    Comment(CommentBlock),
    
    // --- Gouvernance & Sémantique ---
    /// Classification fonctionnelle du bloc (Résumé, Clause légale, etc.)
    Intent(IntentBlock),
    /// Emplacement réservé pour une signature
    SignatureSlot(SignatureSlotBlock),
    /// Marque de révision enveloppant un bloc
    Revision(RevisionBlock),
    
    // --- Dynamique & Structure ---
    /// Structure de répétition conceptuelle
    Iteration(IterationBlock),
    /// Structure conditionnelle symbolique (If/Then/Else)
    Condition(ConditionBlock),
    /// Groupement libre de blocs
    Group(GroupBlock),

    // --- Dialecte Word ---
    /// Note de bas de page (contenu)
    Footnote(FootnoteBlock),
    /// En-tête de page
    Header(HeaderBlock),
    /// Pied de page
    Footer(FooterBlock),
    /// Saut de page sémantique
    PageBreak,
    
    // --- Dialecte Dessin/Slides ---
    /// Forme vectorielle (Rectangle, Cercle, etc.)
    Shape(ShapeBlock),
}

// --- Structures de Blocs ---

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct SectionBlock {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub level: u8,
    pub children: Vec<Block>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ParagraphBlock {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub inlines: Vec<Inline>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ListBlock {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub list_type: ListType,
    pub items: Vec<ListItem>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ListType {
    Ordered,
    Unordered,
    Task,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ListItem {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub content: Vec<Block>,
    pub checked: Option<bool>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct TableBlock {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub rows: Vec<TableRow>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct TableRow {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub cells: Vec<TableCell>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct TableCell {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub content: Vec<Block>,
    pub rowspan: u8,
    pub colspan: u8,
    pub header: bool,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ImageBlock {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub src: String,
    pub alt: Option<String>,
    pub caption: Option<String>,
    pub width: Option<u32>,
    pub height: Option<u32>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct QuoteBlock {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub content: Vec<Block>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CodeBlockBlock {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub language: Option<String>,
    pub code: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct AnchorNode {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub name: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CommentBlock {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub target_id: NodeId,
    pub author: String,
    pub text: String,
    pub resolved: bool,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct IntentBlock {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub intent: NodeIntent,
    pub content: Vec<Block>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum NodeIntent {
    Summary,
    Disclaimer,
    TableOfContents,
    LegalClause,
    Abstract,
    Custom(String),
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct SignatureSlotBlock {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub role: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct RevisionBlock {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub change_type: RevisionType,
    pub content: Vec<Block>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum RevisionType {
    Insertion,
    Deletion,
    Modification,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct IterationBlock {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub intent: String, // ex: "Parcourir chaque ligne"
    pub template: Vec<Block>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ConditionBlock {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub expression: String, // ex: "total > 1000"
    pub then_branch: Vec<Block>,
    pub else_branch: Option<Vec<Block>>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct GroupBlock {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub children: Vec<Block>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct FootnoteBlock {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub number: u32,
    pub content: Vec<Block>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct HeaderBlock {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub content: Vec<Block>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct FooterBlock {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub content: Vec<Block>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ShapeBlock {
    pub id: NodeId,
    pub meta: crate::core::Metadata,
    pub shape_type: String, // ex: "rectangle", "ellipse", "path"
    pub properties: std::collections::BTreeMap<String, String>, // ex: "fill", "stroke"
}

// --- Inline Nodes ---

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum Inline {
    Text(TextInline),
    Bold(BoldInline),
    Italic(ItalicInline),
    Underline(UnderlineInline),
    Strike(StrikeInline),
    Link(LinkInline),
    Code(CodeInline),
    FootnoteRef(FootnoteRefInline),
    StyleRef(StyleRefInline),
    Anchor(AnchorNode),
    Field(FieldInline),
    
    // --- Nouveaux Inlines ---
    /// Valeur typée sémantique
    Value(ValueInline),
    /// Référence croisée dynamique
    CrossRef(CrossRefInline),
    /// Citation bibliographique
    Citation(CitationInline),
    /// Expression de calcul symbolique
    Expression(ExpressionInline),
    /// Marque de révision enveloppant un inline
    Revision(RevisionInline),
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ValueInline {
    pub value_type: ValueType,
    pub raw_value: String,
    pub formatted_value: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ValueType {
    Number,
    Date,
    Currency,
    Percent,
    Boolean,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CrossRefInline {
    pub target_id: NodeId,
    pub display_intent: String, // ex: "page_number", "title", "value"
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CitationInline {
    pub source_id: String,
    pub prefix: Option<String>,
    pub suffix: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ExpressionInline {
    pub formula: String, // ex: "SUM(A1:A10)"
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct RevisionInline {
    pub change_type: RevisionType,
    pub content: Vec<Inline>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct FieldInline {
    pub key: String,
    pub fallback_text: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct TextInline {
    pub text: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct BoldInline {
    pub content: Vec<Inline>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ItalicInline {
    pub content: Vec<Inline>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct UnderlineInline {
    pub content: Vec<Inline>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct StrikeInline {
    pub content: Vec<Inline>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct LinkInline {
    pub url: String,
    pub title: Option<String>,
    pub content: Vec<Inline>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CodeInline {
    pub text: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct FootnoteRefInline {
    pub id: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct StyleRefInline {
    pub style_name: String,
    pub content: Vec<Inline>,
}

// --- Traits Communs ---

pub trait Container {
    fn children(&self) -> &[Block];
    fn children_mut(&mut self) -> &mut Vec<Block>;
}

impl Container for SectionBlock {
    fn children(&self) -> &[Block] { &self.children }
    fn children_mut(&mut self) -> &mut Vec<Block> { &mut self.children }
}

impl Container for ListItem {
    fn children(&self) -> &[Block] { &self.content }
    fn children_mut(&mut self) -> &mut Vec<Block> { &mut self.content }
}

impl Container for TableCell {
    fn children(&self) -> &[Block] { &self.content }
    fn children_mut(&mut self) -> &mut Vec<Block> { &mut self.content }
}

impl Container for QuoteBlock {
    fn children(&self) -> &[Block] { &self.content }
    fn children_mut(&mut self) -> &mut Vec<Block> { &mut self.content }
}

impl Container for FootnoteBlock {
    fn children(&self) -> &[Block] { &self.content }
    fn children_mut(&mut self) -> &mut Vec<Block> { &mut self.content }
}

impl Container for HeaderBlock {
    fn children(&self) -> &[Block] { &self.content }
    fn children_mut(&mut self) -> &mut Vec<Block> { &mut self.content }
}

impl Container for FooterBlock {
    fn children(&self) -> &[Block] { &self.content }
    fn children_mut(&mut self) -> &mut Vec<Block> { &mut self.content }
}

impl Container for GroupBlock {
    fn children(&self) -> &[Block] { &self.children }
    fn children_mut(&mut self) -> &mut Vec<Block> { &mut self.children }
}

impl Container for IntentBlock {
    fn children(&self) -> &[Block] { &self.content }
    fn children_mut(&mut self) -> &mut Vec<Block> { &mut self.content }
}

impl Container for RevisionBlock {
    fn children(&self) -> &[Block] { &self.content }
    fn children_mut(&mut self) -> &mut Vec<Block> { &mut self.content }
}

impl Container for IterationBlock {
    fn children(&self) -> &[Block] { &self.template }
    fn children_mut(&mut self) -> &mut Vec<Block> { &mut self.template }
}
