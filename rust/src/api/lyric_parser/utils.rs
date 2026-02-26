#[cfg(target_arch = "wasm32")]
use wasm_bindgen::prelude::*;

use crate::api::lyric_parser::LyricLine;

pub fn process_lyrics(lines: &mut [LyricLine]) {
    lines.sort_by(|a, b| {
        a.words
            .first()
            .map(|x| x.start_time)
            .cmp(&b.words.first().map(|x| x.start_time))
    });
    const MAX_TIME: u64 = 60039999; // 999:99.999
    for line in lines.iter_mut() {
        line.start_time = line
            .words
            .first()
            .map(|x| x.start_time)
            .unwrap_or(0)
            .clamp(0, MAX_TIME);
        line.end_time = line
            .words
            .last()
            .map(|x| x.end_time)
            .unwrap_or(0)
            .clamp(0, MAX_TIME);
        for word in line.words.iter_mut() {
            word.start_time = word.start_time.clamp(0, MAX_TIME);
            word.end_time = word.end_time.clamp(0, MAX_TIME);
        }
    }
}
