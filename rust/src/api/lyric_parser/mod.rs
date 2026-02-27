use serde::{Deserialize, Serialize};

pub mod eslrc;

pub mod lrc;

pub mod lys;

pub mod qrc;

pub mod ttml;

pub mod yrc;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LyricLineParsed {
    pub start: u64,  // 毫秒
    pub end: u64,
    pub text: String,
    pub words: Vec<LyricWordParsed>,
    pub translation: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LyricWordParsed {
    pub text: String,
    pub start: u64,
    pub end: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ParseResult {
    pub lines: Vec<LyricLineParsed>,
    pub format: String,
}
