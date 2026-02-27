use crate::api::lyric_parser::{LyricLineParsed, LyricWordParsed, ParseResult};

use std::io::Cursor;

pub fn parse_ttml(lyric_content: String) -> ParseResult {
    use amll_lyric::ttml;

    // TTML 需要 BufRead，使用 Cursor
    let result = ttml::parse_ttml(Cursor::new(&lyric_content));

    match result {
        Ok(ttml_lyric) => {
            if ttml_lyric.lines.is_empty() {
                return ParseResult {
                    lines: vec![],
                    format: "error".to_string(),
                };
            }

            let lines: Vec<LyricLineParsed> = ttml_lyric.lines
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
                format: "TTML".to_string(),
            }
        }
        Err(_) => ParseResult {
            lines: vec![],
            format: "error".to_string(),
        }
    }
}