use crate::{LyricLineOwned};

/// LRC 格式
#[cfg(feature = "lrc")]
pub fn parse_lrc(content: String) -> Vec<LyricLineOwned> {
    crate::lrc::parse_lrc(&content)
        .into_iter()
        .map(|line| line.to_owned())
        .collect()
}

#[cfg(feature = "lrc")]
pub fn stringify_lrc(lines: Vec<LyricLineOwned>) -> String {
    let lines_ref: Vec<LyricLine> = lines.iter()
        .map(|line| line.to_ref())
        .collect();
    crate::lrc::stringify_lrc(&lines_ref)
}

/// ESLyric 格式
#[cfg(feature = "eslrc")]
pub fn parse_eslrc(content: String) -> Vec<LyricLineOwned> {
    crate::eslrc::parse_eslrc(&content)
        .into_iter()
        .map(|line| line.to_owned())
        .collect()
}

#[cfg(feature = "eslrc")]
pub fn stringify_eslrc(lines: Vec<LyricLineOwned>) -> String {
    let lines_ref: Vec<LyricLine> = lines.iter()
        .map(|line| line.to_ref())
        .collect();
    crate::eslrc::stringify_eslrc(&lines_ref)
}

/// YRC 格式（网易云）
#[cfg(feature = "yrc")]
pub fn parse_yrc(content: String) -> Vec<LyricLineOwned> {
    crate::yrc::parse_yrc(&content)
        .into_iter()
        .map(|line| line.to_owned())
        .collect()
}

#[cfg(feature = "yrc")]
pub fn stringify_yrc(lines: Vec<LyricLineOwned>) -> String {
    let lines_ref: Vec<LyricLine> = lines.iter()
        .map(|line| line.to_ref())
        .collect();
    crate::yrc::stringify_yrc(&lines_ref)
}

/// QRC 格式（QQ音乐）
#[cfg(feature = "qrc")]
pub fn parse_qrc(content: String) -> Vec<LyricLineOwned> {
    crate::qrc::parse_qrc(&content)
        .into_iter()
        .map(|line| line.to_owned())
        .collect()
}

#[cfg(feature = "qrc")]
pub fn stringify_qrc(lines: Vec<LyricLineOwned>) -> String {
    let lines_ref: Vec<LyricLine> = lines.iter()
        .map(|line| line.to_ref())
        .collect();
    crate::qrc::stringify_qrc(&lines_ref)
}

/// LYS 格式（Lyricify）
#[cfg(feature = "lys")]
pub fn parse_lys(content: String) -> Vec<LyricLineOwned> {
    crate::lys::parse_lys(&content)
        .into_iter()
        .map(|line| line.to_owned())
        .collect()
}

#[cfg(feature = "lys")]
pub fn stringify_lys(lines: Vec<LyricLineOwned>) -> String {
    let lines_ref: Vec<LyricLine> = lines.iter()
        .map(|line| line.to_ref())
        .collect();
    crate::lys::stringify_lys(&lines_ref)
}

/// ASS 格式（仅导出）
#[cfg(feature = "ass")]
pub fn stringify_ass(lines: Vec<LyricLineOwned>) -> String {
    let lines_ref: Vec<LyricLine> = lines.iter()
        .map(|line| line.to_ref())
        .collect();
    crate::ass::stringify_ass(&lines_ref)
}

/// TTML 格式
#[cfg(feature = "ttml")]
pub fn parse_ttml(content: String) -> TTMLLyricOwned {
    crate::ttml::parse_ttml(&content)
}

#[cfg(feature = "ttml")]
pub fn stringify_ttml(ttml: TTMLLyricOwned) -> String {
    crate::ttml::stringify_ttml(ttml)
}