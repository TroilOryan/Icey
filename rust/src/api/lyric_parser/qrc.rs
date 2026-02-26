#[cfg(target_arch = "wasm32")]
use wasm_bindgen::prelude::*;

use crate::{LyricLine, LyricLineOwned, LyricWord, utils::process_lyrics};

use std::fmt::Write;
use std::{borrow::Cow, str::FromStr};

use nom::{
    IResult, Parser, bytes::complete::*, character::complete::line_ending, combinator::opt,
    multi::many0,
};

fn process_time<'a>(
    src: &'a str,
    start_time: &'a str,
    duration: &'a str,
) -> IResult<&'a str, (u64, u64)> {
    let start_time = u64::from_str(start_time);
    if start_time.is_err() {
        return Err(nom::Err::Error(nom::error::Error {
            input: src,
            code: nom::error::ErrorKind::Digit,
        }));
    }
    let start_time = start_time.unwrap();
    let duration = u64::from_str(duration);
    if duration.is_err() {
        return Err(nom::Err::Error(nom::error::Error {
            input: src,
            code: nom::error::ErrorKind::Digit,
        }));
    }
    let duration = duration.unwrap();

    Ok((src, (start_time, duration)))
}

fn parse_time(src: &str) -> IResult<&str, (u64, u64)> {
    let (src, _) = tag("[")(src)?;
    let (src, start_time) = nom::character::complete::digit1(src)?;
    let (src, _) = tag(",")(src)?;
    let (src, duration) = nom::character::complete::digit1(src)?;
    let (src, _) = tag("]")(src)?;

    process_time(src, start_time, duration)
}

fn parse_word_time(src: &str) -> IResult<&str, (u64, u64)> {
    let (src, _) = tag("(")(src)?;
    let (src, start_time) = take_until1(",")(src)?;
    let (src, _) = tag(",")(src)?;
    let (src, duration) = take_until1(")")(src)?;
    let (src, _) = tag(")")(src)?;

    process_time(src, start_time, duration)
}

fn parse_word(src: &str) -> IResult<&str, LyricWord<'_>> {
    for (i, _c) in src.char_indices() {
        if let Ok((nsrc, (start_time, duration))) = parse_word_time(&src[i..]) {
            return Ok((
                nsrc,
                LyricWord {
                    start_time,
                    end_time: start_time + duration,
                    word: Cow::Borrowed(&src[..i]),
                    roman_word: std::borrow::Cow::Borrowed(""),
                },
            ));
        }
    }

    Err(nom::Err::Error(nom::error::Error {
        input: src,
        code: nom::error::ErrorKind::TakeTill1,
    }))
}

#[test]
fn test_word() {
    let _ = dbg!(parse_word("Counting(0,18) (18,18)Stars(36,18)"));
}

fn parse_words(src: &str) -> IResult<&str, Vec<LyricWord<'_>>> {
    let (src, words) = many0(parse_word).parse(src)?;
    Ok((src, words))
}

fn parse_line(src: &str) -> IResult<&str, LyricLine<'_>> {
    let (src, _) = parse_time(src)?;
    match is_not("\r\n")(src) {
        Ok((src, line)) => {
            let (src, _) = opt(line_ending).parse(src)?;
            let (_, words) = parse_words(line)?;
            Ok((
                src,
                LyricLine {
                    words,
                    ..Default::default()
                },
            ))
        }
        Err(nom::Err::Error(nom::error::Error {
            code: nom::error::ErrorKind::IsNot,
            ..
        })) => {
            let (src, words) = parse_words(src)?;
            Ok((
                src,
                LyricLine {
                    words,
                    ..Default::default()
                },
            ))
        }
        Err(e) => Err(e),
    }
}

/// QRC 格式（QQ音乐）
#[cfg(feature = "qrc")]
pub fn parse_qrc(content: String) -> Vec<LyricLineOwned> {
    _parse_qrc(&content)
        .into_iter()
        .map(|line| line.to_owned())
        .collect()
}

fn _parse_qrc<'a>(src: &'a str) -> Vec<LyricLine<'a>> {
    let lines = src.lines();
    let mut result = Vec::with_capacity(lines.size_hint().1.unwrap_or(1024).min(1024));

    for line in lines {
        if let Ok((_, line)) = parse_line(line) {
            result.push(line);
        }
    }

    process_lyrics(&mut result);

    result
}

#[cfg(feature = "qrc")]
pub fn stringify_qrc(lines: Vec<LyricLineOwned>) -> String {
    let lines_ref: Vec<LyricLine> = lines.iter()
        .map(|line| line.to_ref())
        .collect();
    _stringify_qrc(&lines_ref)
}

fn _stringify_qrc(lines: &[LyricLine]) -> String {
    let capacity: usize = lines
        .iter()
        .map(|x| x.words.iter().map(|y| y.word.len()).sum::<usize>() + 32)
        .sum();
    let mut result = String::with_capacity(capacity);

    for line in lines {
        if !line.words.is_empty() {
            let start_time = line.words[0].start_time;
            let duration: u64 = line.words.iter().map(|x| x.end_time - x.start_time).sum();
            write!(result, "[{start_time},{duration}]").unwrap();
            for word in line.words.iter() {
                let start_time = word.start_time;
                let duration = word.end_time - word.start_time;
                result.push_str(&word.word);
                write!(result, "({start_time},{duration})").unwrap();
            }
            result.push('\n');
        }
    }

    result
}
