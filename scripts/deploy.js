const hre = require("hardhat");

async function main() {
  const Voting = await ethers.getContractFactory("Voting");
  const voting = await Voting.deploy();//в скобки вписываем значения конструктора
  await voting.deployed();// доп логика

  console.log("Voting deployed to:", voting.address);//выводит в консоль название контракта и адресс контракта который задеплоили
}

main()// просто запускаем async function 
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
