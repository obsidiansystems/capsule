// use anyhow::{anyhow, Error};
use anyhow::{Error};
use std::str::FromStr;
use std::string::ToString;

pub struct Version {
    pub major: u8,
    pub minor: u8,
    pub patch: u16,
    pub commit_id: String,
    pub pre: String,
}

impl FromStr for Version {
    type Err = Error;

    fn from_str(_s: &str) -> Result<Self, Self::Err> {
        // parse commit id
        // TODO(skylar): Commit id in nix!
        let major = 0;
        let minor = 7;
        let patch = 3;
        let commit_id = "nix".to_string();
        let pre = "nix".to_string();

        Ok(Self {
            major,
            minor,
            patch,
            commit_id,
            pre,
        })
        /*
        let items: Vec<_> = s.split_ascii_whitespace().collect();
        if items.len() > 2 || items.is_empty() {
            return Err(anyhow!(
                "unexpected parts after split whitespaces: {}",
                items.len()
            ));
        }
        let commit_id = items.get(1).map(|s| s.to_string()).unwrap_or_default();
        // parse pre
        let items: Vec<_> = items[0].split("-").collect();
        if items.len() > 2 || items.is_empty() {
            return Err(anyhow!("unexpected parts after split '-': {}", items.len()));
        }
        let pre = items.get(1).map(|s| s.to_string()).unwrap_or_default();
        // parse versions
        let items: Vec<_> = items[0].split(".").collect();
        if items.len() > 3 || items.is_empty() {
            return Err(anyhow!("unexpected parts after split '.': {}", items.len()));
        }
        let major = items[0].parse()?;
        let minor = items[1].parse()?;
        let patch = items[2].parse()?;

        Ok(Self {
            major,
            minor,
            patch,
            pre,
            commit_id,
        })*/
    }
}
impl ToString for Version {
    fn to_string(&self) -> String {
        let mut version = format!("{}.{}.{}", self.major, self.minor, self.patch);
        if !self.pre.is_empty() {
            version.push_str("-");
            version.push_str(&self.pre);
        }
        version.push_str(" ");
        version.push_str(&self.commit_id);
        version.trim().to_string()
    }
}

impl Version {
    pub fn is_compatible(&self, version: &Version) -> bool {
        self.major == version.major && self.minor == version.minor
    }

    pub fn current() -> Self {
        let major = env!("CARGO_PKG_VERSION_MAJOR")
            .parse::<u8>()
            .expect("CARGO_PKG_VERSION_MAJOR parse success");
        let minor = env!("CARGO_PKG_VERSION_MINOR")
            .parse::<u8>()
            .expect("CARGO_PKG_VERSION_MINOR parse success");
        let patch = env!("CARGO_PKG_VERSION_PATCH")
            .parse::<u16>()
            .expect("CARGO_PKG_VERSION_PATCH parse success");
        let pre = env!("CARGO_PKG_VERSION_PRE").to_string();
        let commit_id = env!("COMMIT_ID").to_string();
        Self {
            major,
            minor,
            patch,
            pre,
            commit_id,
        }
    }
}
