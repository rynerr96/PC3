require("dotenv").config();

const {
  getRole,
  verify,
  ex,
  printAddress,
  deploySC,
  deploySCNoUp,
} = require("../utils");

var BURNER_ROLE = getRole("BURNER_ROLE");

var MINTER_ROLE = getRole("MINTER_ROLE");

/**async function deployMumbai() {
  var relayerAddress = "0x6E929F43a5ED5Cb767fBC5FA7D817db39ca124Be";
  var name = "Mi Primer NFT";
  var symbol = "MPRNFT";
  var nftContract = await deploySC("MiPrimerNft");
  var implementation = await printAddress("NFT", nftContract.address);

  // set up
  await ex(nftContract, "grantRole", [MINTER_ROLE, relayerAddress], "GR");
  await verify(implementation, "MiPrimerNft", []);
}*/

async function deployGoerli() {
  var gnosisSafeAddress = "0x1a42979EDB230080cA294C312e682c0e62399384";
  var name = "Mi Primer Token";
  var symbol = "MPT";
  var miPrimerTokenContract = await deploySC("MyTokenMiPrimerToken", []);
  var implementation = await printAddress(
    "MiPrimerToken",
    miPrimerTokenContract.address
  );
  // setup
  await ex(
    miPrimerTokenContract,
    "setGnosisSafeAddress",
    [gnosisSafeAddress],
    "Set Gnosis Safe Address"
  );

  await verify(implementation, "MyTokenMiPrimerToken", []);
}

/**async function sale() {
  const PublicSale = await ethers.getContractFactory("PublicSale");
  const publicSale = await PublicSale.deploy(
    // aquí  las direcciones de las cuentas
    "0x404b5d7e77fb32ff5a68779acf1c63c2fb847fde",
    "0xf193c7adc06853f2497e54e00b58e9dba1558d8d",
    "0x1a42979edb230080ca294c312e682c0e62399384",
    "0x404b5d7e77fb32ff5a68779acf1c63c2fb847fde"
  );

  await publicSale.deployed();

  console.log("PublicSale deployed to:", publicSale.address);
}*/

/**async function usd() {
  const [deployer] = await ethers.getSigners();
  // Despliegue del contrato USDCoin
  const USDCoin = await ethers.getContractFactory("USDCoin");
  const usdCoin = await USDCoin.deploy();
  await usdCoin.deployed();
  console.log("USDC deployed to:", usdCoin.address);
  console.log("Deployment completed");
}*/

deployGoerli().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

/**deployMumbai().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});*/

/**usd()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });*/

/**sale()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });*/
