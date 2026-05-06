import fs from 'fs';

const msg_path = process.argv[2];

if (msg_path) {
  const content = fs.readFileSync(msg_path, 'utf-8');
  
  var newc = content
    .replace(/fix-ogi:/gi, 'fix(ObbyGameInfobox):')
    .replace(/feat-ogi:/gi, 'feat(ObbyGameInfobox):')
    .replace(/chore-ogi:/gi, 'chore(ObbyGameInfobox):')
    .replace(/style-ogi:/gi, 'style(ObbyGameInfobox):')
    .replace(/fix-gi:/gi, 'fix(GroupInfobox):')
    .replace(/feat-gi:/gi, 'feat(GroupInfobox):')
    .replace(/chore-gi:/gi, 'chore(GroupInfobox):')
    .replace(/style-gi:/gi, 'style(GroupInfobox):')
    .replace(/fix-pol:/gi, 'fix(PlayerObbiesList):')
    .replace(/feat-pol:/gi, 'feat(PlayerObbiesList):')
    .replace(/chore-pol:/gi, 'chore(PlayerObbiesList):')
    .replace(/style-pol:/gi, 'style(PlayerObbiesList):')
    .replace(/fix-pi:/gi, 'fix(PlayerInfobox):')
    .replace(/feat-pi:/gi, 'feat(PlayerInfobox):')
    .replace(/chore-pi:/gi, 'chore(PlayerInfobox):')
    .replace(/style-pi:/gi, 'style(PlayerInfobox):');

  fs.writeFileSync(msg_path, newc);
}