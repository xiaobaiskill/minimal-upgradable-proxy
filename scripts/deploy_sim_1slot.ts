import { ethers } from "hardhat";
import { pack } from "@ethersproject/solidity";

async function main() {
  const V1 = await ethers.getContractFactory("SimV1");
  const v1 = await V1.deploy(1);
  await v1.deployed();

  // deploy proxy contract
  const code = pack(
    ["bytes1", "uint8", "bytes1", "address", "bytes"],
    [
      "0x60",
      await v1.getImplementSlot(),
      "0x73",
      v1.address,
      "0x8155600960305f3960f81b60095260106039600a39601a5ff3365f5f375f5f365f60545af43d5f5f3e3d5f82601857fd5bf3",
    ]
  );
  const Proxy = new ethers.ContractFactory(
    "[]",
    code.slice(2),
    await ethers.getSigner()
  );
  const proxy = await Proxy.deploy();
  await proxy.deployed();
  console.log("deploy proxy contract:", proxy.address);

  await (await v1.attach(proxy.address).init()).wait();
  await (await v1.attach(proxy.address).setNumber(11)).wait();

  const V2 = await ethers.getContractFactory("SimV2");
  const v2 = await V2.deploy(2);
  await v2.deployed();

  await (await v1.attach(proxy.address).upgrade(v2.address)).wait();
  await (await v2.attach(proxy.address).addNumber(1)).wait();
  console.log("number:", await v2.attach(proxy.address).number());
  console.log("owner:", await v2.attach(proxy.address).owner());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
