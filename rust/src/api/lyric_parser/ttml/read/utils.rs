use nom::{bytes::complete::*, combinator::*, *};
use std::str::FromStr;

pub fn parse_hour(input: &[u8]) -> IResult<&[u8], u64> {
    let (input, result) = take_while_m_n(2, 3, |x: u8| x.is_dec_digit())(input)?;
    let result = u64::from_str(std::str::from_utf8(result).unwrap()).unwrap();
    Ok((input, result))
}

pub fn parse_minutes_or_seconds(input: &[u8]) -> IResult<&[u8], u64> {
    let (input, result) = take_while_m_n(1, 2, |x: u8| x.is_dec_digit())(input)?;
    let result = u64::from_str(std::str::from_utf8(result).unwrap()).unwrap();
    Ok((input, result))
}

pub fn parse_fraction(input: &[u8]) -> IResult<&[u8], u64> {
    let (input, _) = tag(b".".as_slice()).parse(input)?;
    let (input, result) = take_while1(|x: u8| x.is_dec_digit())(input)?;
    let frac_str = std::str::from_utf8(result).unwrap();
    let result = match frac_str.len() {
        0 => unreachable!(),
        1 => u64::from_str(frac_str).unwrap() * 100,
        2 => u64::from_str(frac_str).unwrap() * 10,
        3 => u64::from_str(frac_str).unwrap(),
        _ => u64::from_str(&frac_str[0..3]).unwrap(),
    };
    Ok((input, result))
}

pub fn parse_timestamp(input: &[u8]) -> IResult<&[u8], u64> {
    match (
        parse_hour,
        tag(b":".as_slice()),
        parse_minutes_or_seconds,
        tag(b":".as_slice()),
        parse_minutes_or_seconds,
        opt(parse_fraction),
        eof,
    )
        .parse(input)
    {
        Ok((input, result)) => {
            let time = result.0 * 60 * 60 * 1000 + result.2 * 60 * 1000 + result.4 * 1000;
            if let Some(frac) = result.5 {
                Ok((input, time + frac))
            } else {
                Ok((input, time))
            }
        }
        Err(_) => match (
            parse_minutes_or_seconds,
            tag(b":".as_slice()),
            parse_minutes_or_seconds,
            opt(parse_fraction),
            eof,
        )
            .parse(input)
        {
            Ok((input, result)) => {
                let time = result.0 * 60 * 1000 + result.2 * 1000;
                if let Some(frac) = result.3 {
                    Ok((input, time + frac))
                } else {
                    Ok((input, time))
                }
            }
            Err(_) => {
                match (
                    parse_minutes_or_seconds,
                    opt(parse_fraction),
                    opt(tag("s")),
                    eof,
                )
                    .parse(input)
                {
                    Ok((input, result)) => {
                        let time = result.0 * 1000;
                        if let Some(frac) = result.1 {
                            Ok((input, time + frac))
                        } else {
                            Ok((input, time))
                        }
                    }
                    Err(err) => Err(err),
                }
            }
        },
    }
}
