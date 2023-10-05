async function main() {
    const ChainBattles = await ethers.deployContract("ChainBattles")
    const chainBattles = await ChainBattles.waitForDeployment()
    console.log("ChainBattles deployed to: ", chainBattles.target)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
