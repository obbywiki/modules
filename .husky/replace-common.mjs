import fs from 'fs';

const msg_path = process.argv[2];

if (msg_path) {
  const content = fs.readFileSync(msg_path, 'utf-8');
  
  var newc = content
  newc = content.replace(/fix-ogi:/g, 'fix(ObbyGameInfobox):');
  newc = content.replace(/fix-gi:/g, 'fix(GroupInfobox):');

  fs.writeFileSync(msg_path, newc);
}