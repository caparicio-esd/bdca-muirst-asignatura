const AsignaturaLite = artifacts.require("AsignaturaLite");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("AsignaturaLite", function (/* accounts */) {
  it("should assert true", async function () {
    await AsignaturaLite.deployed();
    return assert.isTrue(true);
  });
});
