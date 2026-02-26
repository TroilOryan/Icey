use std::io::BufRead;

pub mod error;
pub mod parser;
pub mod utils;

pub use error::TTMLError;
use super::TTMLLyric;

/// TTML 格式
#[cfg(feature = "ttml")]
pub fn parse_ttml(content: String) -> TTMLLyricOwned {
    _parse_ttml(&content)
}

pub fn _parse_ttml<'a>(data: impl BufRead) -> std::result::Result<TTMLLyric<'a>, TTMLError> {
    let parser = parser::TTMLParser::new(data);
    parser.parse()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::LyricLine;

    #[test]
    fn test_ttml() {
        const TEST_TTML: &str = include_str!("../../../test/test.ttml");
        let t = std::time::Instant::now();
        let r = _parse_ttml(TEST_TTML.as_bytes());
        let t = t.elapsed();
        match r {
            Ok(ttml) => {
                println!("ttml: {ttml:#?}");
                let lys = crate::lys::stringify_lys(&ttml.lines);
                println!("lys:\n{lys}");
            }
            Err(e) => {
                let mut pos = e.pos();
                for (i, l) in TEST_TTML.lines().enumerate() {
                    if pos < l.len() {
                        println!("error: {} at {}:{}: {:?}", e, i + 1, pos + 1, l);
                        break;
                    }
                    pos -= l.len() + 1;
                }
            }
        }
        println!("ttml: {t:?}");
    }

    #[test]
    fn test_timestamp() {
        use super::utils::parse_timestamp;
        assert_eq!(
            parse_timestamp("00:00.088".as_bytes()),
            Ok(("".as_bytes(), 88))
        );
        assert_eq!(
            parse_timestamp("00:45:12.2".as_bytes()),
            Ok(("".as_bytes(), 2712200))
        );
        assert_eq!(
            parse_timestamp("00:00:10.254".as_bytes()),
            Ok(("".as_bytes(), 10254))
        );
        assert_eq!(
            parse_timestamp("00:01:10".as_bytes()),
            Ok(("".as_bytes(), 70000))
        );
        assert_eq!(
            parse_timestamp("10.24".as_bytes()),
            Ok(("".as_bytes(), 10240))
        );
    }

    // Add other tests from read.rs here...
    #[test]
    fn test_parse_ttml_basic() {
        const TTML_WITH_ENTITIES: &str = r#"<tt xmlns="http://www.w3.org/ns/ttml" xmlns:itunes="http://music.apple.com/lyric-ttml-internal" xmlns:ttm="http://www.w3.org/ns/ttml#metadata" itunes:timing="Word" xml:lang="ja"><head><metadata><ttm:agent type="person" xml:id="v1"/><ttm:agent type="other" xml:id="v2000"/><iTunesMetadata xmlns="http://music.apple.com/lyric-ttml-internal" leadingSilence="0.640"><translations/><songwriters><songwriter>Ayase</songwriter></songwriters><transliterations><transliteration automaticallyCreated="true" xml:lang="ja-Latn"><text for="L51"><span xmlns="http://www.w3.org/ns/ttml">sorede</span><span xmlns="http://www.w3.org/ns/ttml">mo</span></text></transliteration></transliterations></iTunesMetadata></metadata></head><body><div><p begin="2:33.455" end="2:35.307" itunes:key="L51" ttm:agent="v1"><span begin="2:33.455" end="2:34.068">それで</span><span begin="2:34.068" end="2:35.307">も</span></p></div></body></tt>"#;

        let ttml = _parse_ttml(TTML_WITH_ENTITIES.as_bytes()).unwrap();
        assert_eq!(ttml.lines.len(), 1);
        let line = &ttml.lines[0];
        assert_eq!(line.words.len(), 2);
        assert_eq!(line.words[0].word, "それで");
        assert_eq!(line.words[1].word, "も");
    }

    #[test]
    fn test_parse_ttml_with_entities() {
        const TTML_WITH_ENTITIES: &str = r#"<tt><body><div><p begin="0" end="5"><span begin="0" end="5">Test: &lt; &gt; &amp; &quot; &apos;</span></p></div></body></tt>"#;

        let result = _parse_ttml(TTML_WITH_ENTITIES.as_bytes());

        assert!(result.is_ok(), "解析TTML应该成功");
        let ttml_lyric = result.unwrap();

        assert_eq!(ttml_lyric.lines.len(), 1, "应该解析出一行歌词");
        let line = &ttml_lyric.lines[0];

        assert_eq!(line.words.len(), 1, "该行歌词应该包含一个音节");
        let word = &line.words[0];

        let expected_text = "Test: < > & \" '";
        assert_eq!(word.word, expected_text, "实体引用没有被正确解码");
    }

    #[test]
    fn test_parse_apple_music_word_by_word_lyrics() {
        const TTML_EXAMPLE: &str = r##"<tt xmlns="http://www.w3.org/ns/ttml" xmlns:itunes="http://music.apple.com/lyric-ttml-internal" xml:lang="ja"><head><metadata><iTunesMetadata xmlns="http://music.apple.com/lyric-ttml-internal"><translations><translation type="replacement" xml:lang="en"><text for="L1"><span xmlns="http://www.w3.org/ns/ttml">This</span> <span xmlns="http://www.w3.org/ns/ttml">is</span></text><text for="L2"><span xmlns="http://www.w3.org/ns/ttml">a test</span></text></translation></translations><transliterations><transliteration xml:lang="ja-Latn"><text for="L1"><span xmlns="http://www.w3.org/ns/ttml">ko</span><span xmlns="http://www.w3.org/ns/ttml">re</span><span xmlns="http://www.w3.org/ns/ttml">wa</span></text><text for="L2"><span xmlns="http://www.w3.org/ns/ttml">tesuto</span></text></transliteration></transliterations></iTunesMetadata></metadata></head><body><div><p begin="10s" end="12s" itunes:key="L1"><span begin="10s" end="12s">これは</span></p><p begin="13s" end="15s" itunes:key="L2"><span begin="13s" end="15s">テスト</span></p><p begin="16s" end="18s" itunes:key="L3"><span begin="16s" end="18s">未翻译行</span></p></div></body></tt>"##;

        let result = _parse_ttml(TTML_EXAMPLE.as_bytes());

        let ttml_lyric = result.unwrap();

        assert_eq!(ttml_lyric.lines.len(), 3, "应该解析出三行歌词");

        let line1 = &ttml_lyric.lines[0];
        assert_eq!(line1.words[0].word, "これは", "第一行原文不匹配");
        assert_eq!(line1.translated_lyric, "This is", "第一行逐字翻译拼接错误");
        assert_eq!(line1.roman_lyric, "korewa", "第一行逐字音译拼接错误");

        let line2 = &ttml_lyric.lines[1];
        assert_eq!(line2.words[0].word, "テスト", "第二行原文不匹配");
        assert_eq!(line2.translated_lyric, "a test", "第二行逐字翻译拼接错误");
        assert_eq!(line2.roman_lyric, "tesuto", "第二行逐字音译拼接错误");

        let line3 = &ttml_lyric.lines[2];
        assert_eq!(line3.words[0].word, "未翻译行", "第三行原文不匹配");
        assert!(line3.translated_lyric.is_empty(), "第三行不应有翻译");
        assert!(line3.roman_lyric.is_empty(), "第三行不应有音译");
    }
}
