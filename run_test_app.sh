#!/usr/bin/bash
# Run this inside `nix develop`
set -e

DIR=$(pwd)

cd /tmp
rm -rf forum-lit-open-dev

hc-scaffold web-app forum-lit-open-dev --setup-nix true --template app --templates-path ${DIR}/.templates

cd forum-lit-open-dev

nix develop --command bash -c "
set -e
hc-scaffold dna forum 

hc-scaffold zome posts --integrity dnas/forum/zomes/integrity/ --coordinator dnas/forum/zomes/coordinator/
hc-scaffold entry-type post --reference-entry-hash false --crud crud --link-from-original-to-each-update true --fields title:String:TextField,needs:Vec\<String\>:TextField
hc-scaffold entry-type comment --reference-entry-hash false --crud crud --link-from-original-to-each-update false --fields post_hash:ActionHash::Post
hc-scaffold entry-type like --reference-entry-hash false --crud crd --fields like_hash:Option\<ActionHash\>::Like,image_hash:EntryHash:Image,agent:AgentPubKey:SearchAgent
hc-scaffold entry-type certificate --reference-entry-hash true --crud cr --fields post_hash:ActionHash::Post,agent:AgentPubKey::certified,certifications_hashes:Vec\<EntryHash\>::Certificate,certificate_type:Enum::CertificateType:TypeOne.TypeTwo,dna_hash:DnaHash

hc-scaffold collection global all_posts post 
hc-scaffold collection by-author posts_by_author post
hc-scaffold collection global all_posts_entry_hash post:EntryHash
hc-scaffold collection by-author posts_by_author_entry_hash post:EntryHash

hc-scaffold link-type post like --delete true --bidireccional false
hc-scaffold link-type comment like:EntryHash --delete true --bidireccional true
hc-scaffold link-type certificate:EntryHash like --delete false --bidireccional false
hc-scaffold link-type agent:creator post:EntryHash --delete false --bidireccional true

hc-scaffold zome profiles --coordinator dnas/forum/zomes/coordinator --integrity dnas/forum/zomes/integrity
hc-scaffold zome file_storage --coordinator dnas/forum/zomes/coordinator --integrity dnas/forum/zomes/integrity

sed -i \"s/holochain_integrity_types = \\\"=0.1.2\\\"/holochain_integrity_types = \\\"=0.2.2\\\"/g\" Cargo.toml
cargo clean

cargo add -p profiles hc_zome_profiles_coordinator
echo \"extern crate hc_zome_profiles_coordinator;\" > dnas/forum/zomes/coordinator/profiles/src/lib.rs
cargo add -p profiles_integrity hc_zome_profiles_integrity
echo \"extern crate hc_zome_profiles_integrity;\" > dnas/forum/zomes/integrity/profiles/src/lib.rs
cargo add -p file_storage hc_zome_file_storage_coordinator
echo \"extern crate hc_zome_file_storage_coordinator;\" > dnas/forum/zomes/coordinator/file_storage/src/lib.rs
cargo add -p file_storage_integrity hc_zome_file_storage_integrity
echo \"extern crate hc_zome_file_storage_integrity;\" > dnas/forum/zomes/integrity/file_storage/src/lib.rs

npm i

npm i -w ui @holochain-open-dev/file-storage

npm run format -w ui
npm run lint -w ui
npm run build -w ui

npm t
"
