use crate::api::lyric_parser::{LyricLineParsed, LyricWordParsed, ParseResult};

pub fn parse_yrc(lyric_content: String) -> ParseResult {
    use amll_lyric::yrc;

    let lyric_vec = yrc::parse_yrc(&lyric_content);

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
        format: "YRC".to_string(),
    }
}
