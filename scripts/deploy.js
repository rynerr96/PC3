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

/**async function deployGoerli() {
  var gnosisSafeAddress = "0x1a42979EDB230080cA294C312e682c0e62399384";
  var name = "MiPrimerToken";
  var symbol = "MPT";

  // Despliega el contrato MyTokenMiPrimerToken
  var miPrimerTokenContract = await deploySC("MyTokenMiPrimerToken", []);

  // Imprime la dirección del contrato y su implementación
  var implementation = await printAddress(
    "MiPrimerToken",
    miPrimerTokenContract.address
  );

  // Configura la dirección de Gnosis Safe en el contrato
  await ex(
    miPrimerTokenContract,
    "setGnosisSafeAddress",
    [gnosisSafeAddress],
    "Set Gnosis Safe Address"
  );

  // Mintea los tokens llamando a la función mint del contrato
  var amountToMint = 10000; // Cantidad de tokens a mintear
  await ex(
    miPrimerTokenContract,
    "mint",
    [gnosisSafeAddress, amountToMint],
    "Mint Tokens"
  );

  // Verifica la implementación del contrato
  await verify(implementation, "MyTokenMiPrimerToken", []);
}*/

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

/**async function sale() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Desplegando contrato con la cuenta:", deployer.address);

  const PublicSale = await hre.ethers.getContractFactory("PublicSale");
  const publicSale = await PublicSale.deploy();

  await publicSale.deployed();

  console.log(
    "Contrato PublicSale desplegado en la dirección:",
    publicSale.address
  );
}*/

async function deployUSDCoin() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying USDCoin...");

  const USDCoin = await ethers.getContractFactory("USDCoin");
  const usdCoin = await USDCoin.deploy();
  await usdCoin.deployed();

  console.log("USDCoin deployed at:", usdCoin.address);

  const amountToMint = ethers.utils.parseUnits("1000000000", 6); // 1,000,000,000 tokens with 6 decimal places
  const recipientAddress = "0xf38f79423ACefeb5508dD33E615203dff2893225";
  await ex(
    usdCoin.connect(deployer),
    "mint",
    [recipientAddress, amountToMint],
    "Mint Tokens"
  );

  console.log("Tokens minteados:", amountToMint.toString());
  console.log("Tokens enviados a la dirección:", recipientAddress);
}

/**deployGoerli().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});*/

/**deployMumbai().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});*/

deployUSDCoin()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

/**sale()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });*/
