import { ethers } from "hardhat";
import { pack } from "@ethersproject/solidity";

async function main() {
  const Examplev1 = await ethers.getContractFactory("Example0V1");
  const examplev1 = await Examplev1.deploy();
  await examplev1.deployed();

  // proxy's code
  const code = pack(
    ["bytes1","address", "bytes"],
    [
      "0x73",
      examplev1.address,
      "0x5f55600960285f396010603160093960195ff3365f5f375f5f365f5f545af43d5f5f3e3d5f82601757fd5bf3",
    ]
  );
  const proxyAddr = ethers.utils.getCreate2Address(
    examplev1.address,
    "0x0000000000000000000000000000000000000000000000000000000000000000",
    ethers.utils.keccak256(code)
  );
  console.log("proxy contract", proxyAddr);

  await (await examplev1.attach(proxyAddr).setNumber(11)).wait();

  const Examplev2 = await ethers.getContractFactory("Example0V2");
  const examplev2 = await Examplev2.deploy();
  await examplev2.deployed();

  await (await examplev1.attach(proxyAddr).upgrade(examplev2.address)).wait();
  const tx = await examplev2.attach(proxyAddr).addNumber(1);
  await tx.wait();
  console.log("number:", await examplev2.attach(proxyAddr).number());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
