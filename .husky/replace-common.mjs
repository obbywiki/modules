import fs from 'fs';

const msg_path = process.argv[2];

if (msg_path) {
  const content = fs.readFileSync(msg_path, 'utf-8');
  
  var newc = content
    .replace(/fix-ogi:/gi, 'fix(ObbyGameInfobox):')
    .replace(/fix-gi:/gi, 'fix(GroupInfobox):')
    .replace(/feat-ogi:/gi, 'feat(ObbyGameInfobox):')
    .replace(/feat-gi:/gi, 'feat(GroupInfobox):')
    .replace(/chore-ogi:/gi, 'chore(ObbyGameInfobox):')
    .replace(/chore-gi:/gi, 'chore(GroupInfobox):')
    .replace(/style-ogi:/gi, 'style(ObbyGameInfobox):')
    .replace(/style-gi:/gi, 'style(GroupInfobox):');

  fs.writeFileSync(msg_path, newc);
}