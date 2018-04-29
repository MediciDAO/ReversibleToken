const EtherToken = artifacts.require('EtherToken.sol');

contract('EtherToken', function (accounts) {

    let token;

    beforeEach(async () => {
        token = await EtherToken.new();
    });

    it('should allow depositing and withdrawing ether', async () => {
        await token.deposit({value: 10, from: accounts[0]});
        assert.equal(10, await token.balanceOf(accounts[0]));

        await token.withdraw('10', {from: accounts[0]});
        assert.equal(0, await token.balanceOf(accounts[0]));
    });
});
