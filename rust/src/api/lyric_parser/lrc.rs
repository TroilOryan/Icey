use crate::api::lyric_parser::{convert_lyric_line, LyricLineParsed, LyricWordParsed, ParseResult};

pub fn parse_lrc(lyric_content: String) -> ParseResult {
    use amll_lyric::lrc;

    let lyric_vec = lrc::parse_lrc(&lyric_content);

    if lyric_vec.is_empty() {
        return ParseResult {
            lines: vec![],
            format: "error".to_string(),
        };
    }

    let lines: Vec<LyricLineParsed> = lyric_vec
            .into_iter()
            .map(|line| LyricLineParsed {
                start: line.start_time as u64,
                end: line.end_time as u64,
                text: line
                    .words
                    .iter()
                    .map(|x| x.word.to_string())
                    .collect(),
                words: line
                    .words
                    .into_iter()
                    .map(|word| LyricWordParsed {
                        text: word.word.to_string(),
                        start: word.start_time as u64,
                        end: word.end_time as u64,
                    })
                    .collect(),
                translation: line.translated_lyric.to_string(),
            })
            .collect();

    ParseResult {
        lines,
        format: "LRC".to_string(),
    }
}