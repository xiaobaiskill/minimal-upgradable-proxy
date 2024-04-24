import { Other } from "../typechain/Other";
import { Provider } from "@ethersproject/providers";
import { Contract, Wallet } from "ethers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { pack } from "@ethersproject/solidity";

let other: Other;
describe("example test  for 0 slot", function () {
    before("deploy other", async function () {
        // deploy SimV1
        const V1 = await ethers.getContractFactory("other1");
        const v1 = await V1.deploy(true);
        await v1.deployed();

        const code = pack(
            ["bytes1", "address", "bytes"],
            [
                "0x73",
                v1.address,
                "0x3d55601a60213d39601a3df3363d3d373d3d3d363d3d545af43d82803e3d8282601857fd5bf3",
            ]
        );

        const other1 = ethers.utils.getCreate2Address(
            v1.address,
            "0x0000000000000000000000000000000000000000000000000000000000000000",
            ethers.utils.keccak256(code)
        );
        await v1.attach(other1).init(11);
        console.log("v1 contract", other1);


        const V2 = await ethers.getContractFactory("other2");
        const other2 = await V2.deploy(2);
        await other2.deployed();
        console.log("v2 contract", other2.address);


        const otherFactory = await ethers.getContractFactory("other");
        other = await otherFactory.deploy(other1, other2.address);
        await other.deployed();

        console.log("other contract", other.address);
    });

    it("test get numbet", async function () {
        console.log("get number1", await other.getNumber1())
        console.log("get number2", await other.getNumber2())
        expect(await other.getNumber1()).to.equal(await other.getNumber2())

    });
});
