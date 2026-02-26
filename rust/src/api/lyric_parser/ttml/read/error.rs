use quick_xml::events::attributes::AttrError;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum TTMLError {
    #[error("unexpected tt element at {0}")]
    UnexpectedTTElement(usize),
    #[error("unexpected head element at {0}")]
    UnexpectedHeadElement(usize),
    #[error("unexpected metadata element at {0}")]
    UnexpectedMetadataElement(usize),
    #[error("unexpected ttml:agent element at {0}")]
    UnexpectedTtmlAgentElement(usize),
    #[error("unexpected amll:meta element at {0}")]
    UnexpectedAmllMetaElement(usize),
    #[error("unexpected body element at {0}")]
    UnexpectedBodyElement(usize),
    #[error("unexpected div element at {0}")]
    UnexpectedDivElement(usize),
    #[error("unexpected p element at {0}")]
    UnexpectedPElement(usize),
    #[error("unexpected span element at {0}")]
    UnexpectedSpanElement(usize),
    #[error("xml attr error at {0}: {1}")]
    XmlAttrError(usize, AttrError),
    #[error("xml error on parsing attr timestamp at {0}")]
    XmlTimeStampError(usize),
    #[error("xml error at {0}: {1}")]
    XmlError(usize, quick_xml::Error),
}

impl TTMLError {
    pub fn pos(&self) -> usize {
        match self {
            TTMLError::UnexpectedTTElement(pos) => *pos,
            TTMLError::UnexpectedHeadElement(pos) => *pos,
            TTMLError::UnexpectedMetadataElement(pos) => *pos,
            TTMLError::UnexpectedTtmlAgentElement(pos) => *pos,
            TTMLError::UnexpectedAmllMetaElement(pos) => *pos,
            TTMLError::UnexpectedBodyElement(pos) => *pos,
            TTMLError::UnexpectedDivElement(pos) => *pos,
            TTMLError::UnexpectedPElement(pos) => *pos,
            TTMLError::UnexpectedSpanElement(pos) => *pos,
            TTMLError::XmlAttrError(pos, _) => *pos,
            TTMLError::XmlTimeStampError(pos) => *pos,
            TTMLError::XmlError(pos, _) => *pos,
        }
    }
}
