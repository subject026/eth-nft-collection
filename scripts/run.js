const main = async () => {
  // compiles our contract, generates /artifacts
  const nftContractFactory = await hre.ethers.getContractFactory("MyEpicNFT");

  // deploy?!
  const nftContract = await nftContractFactory.deploy();
  await nftContract.deployed();
  console.log("Contract deployed to:", nftContract.address);

  let { totalMinted, leftToMint } = await nftContract.getCurrentMinted();
  // let { totalMinted, leftToMint } = currentMinted;

  console.log("minted so far: ", totalMinted.toNumber());
  console.log("left to mint: ", leftToMint.toNumber());

  let txn = await nftContract.makeAnEpicNFT();
  await txn.wait();

  txn = await nftContract.makeAnEpicNFT();
  await txn.wait();

  ({ totalMinted, leftToMint } = await nftContract.getCurrentMinted());
  console.log("minted so far: ", totalMinted.toNumber());
  console.log("left to mint: ", leftToMint.toNumber());
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
