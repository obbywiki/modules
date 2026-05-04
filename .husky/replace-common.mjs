import fs from 'fs';

const msg_path = process.argv[2];

console.log(msg_path);

if (msg_path) {
  const content = fs.readFileSync(msg_path, 'utf-8');
  
  var newc = content
    .replace(/fix-ogi:/gi, 'fix(ObbyGameInfobox):')
    .replace(/fix-gi:/gi, 'fix(GroupInfobox):')
    .replace(/feat-ogi:/gi, 'feat(ObbyGameInfobox):')
    .replace(/feat-gi:/gi, 'feat(GroupInfobox):');

  fs.writeFileSync(msg_path, newc);
