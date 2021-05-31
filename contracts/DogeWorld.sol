/**
 *Submitted for verification at BscScan.com on 2021-05-28
*/

/*

 :::::::-.      ...       .,-:::::/ .,::::::      .::    .   .:::  ...    :::::::..    :::   :::::::-.  
 ;;,   `';, .;;;;;;;.  ,;;-'````'  ;;;;''''      ';;,  ;;  ;;;'.;;;;;;;. ;;;;``;;;;   ;;;    ;;,   `';,
 [[     [[,[[     \[[,[[[   [[[[[[/[[cccc        '[[, [[, [[',[[     \[[,[[[,/[[['   [[[    `[[     [[
 $$,    $$$$$,     $$$"$$c.    "$$ $$""""          Y$c$$$c$P $$$,     $$$$$$$$$c     $$'     $$,    $$
 888_,o8P'"888,_ _,88P `Y8bo,,,o88o888oo,__         "88"888  "888,_ _,88P888b "88bo,o88oo,.__888_,o8P'
 MMMMP"`    "YMMMMMP"    `'YMUP"YMM""""YUMMM         "M "M"    "YMMMMMP" MMMM   "W" """"YUMMMMMMMP"`  


Welcome to Doge World.
A Dogecoin Buyback Protocol, Auto Staking, Charity and Coummunity Fund Driven Token with Burn Baby.

                                                                                        Slim Dusty.
*/

// SPDX-License-Identifier: Unlicensed


contract DogeWorld is Context, IERC20, Sanction {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public Wallets;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 40000 * 10**6 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 private _tBurnTotal;

    string private _name = "DogeWorld";
    string private _symbol = "DOGEWORLD";
    uint8 private _decimals = 9;
    
    uint256 public _taxFee = 2;
    uint256 private _previousTaxFee = _taxFee;
    
    uint256 public _liquidityFee = 2;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _burnFee = 2;
    uint256 private _previousburnFee = _burnFee;

    uint256 public _communityFee = 1;
    uint256 private _previousCommunityFee = _communityFee;

    uint256 public _charityFee = 1;
    uint256 private _previousCharityFee = _charityFee;
    
    address public _communityAddress;
    address public _charityAddress;  
    address public _liquidityAddress; 
    address public _liquidityPairAddie;
    address public _swapForwardAddress;

    address private _dogeAddress = 0xbA2aE424d960c26247Dd6c32edC70B295c744C43;
    
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public autoSellForCommunity = true;
    bool public autoSellForCharity = true;
    bool public autoAddToLiquidity = true;
    bool public swapForBNB = true;
        
    uint256 public _maxTxAmount = 1000 * 10**6 * 10**9;
    
    uint256 private numTokensSellToAddToLiquidity = 5 * 10**6 * 10**9;

    
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );    
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor (address _owner1, address _owner2, address _owner3, address _owner4, address communityAddress, address charityAddress, address liquidityAddress, address swapForwardAddress)  public Sanction(_owner1, _owner2, _owner3, _owner4)  {
        
        
        _liquidityAddress = liquidityAddress;
        _communityAddress = communityAddress;
        _charityAddress = charityAddress;    

        _liquidityPairAddie = address(_dogeAddress);   /// Set to Wrapped Doge
        _swapForwardAddress = swapForwardAddress; // Used to send pancake swapped doge/bnb back to contract
        
        _rOwned[_owner1] = _rTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);  // V2!
         // Create a uniswap pair for this new token                                                                        
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _liquidityPairAddie);  // _uniswapV2Router.WETH()

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_communityAddress] = true;
        _isExcludedFromFee[_charityAddress] = true;
        _isExcludedFromFee[_liquidityAddress] = true;
        
        // Exlude deployer from fee
        _isExcludedFromFee[_owner1] = true;
        
        
        
        emit Transfer(address(0), _owner1, _tTotal);   
        
    }
    
    // identifiers used for approving a function
    enum ActionType {
        empty,                              // 0
        excludeFromFee,                     // 1
        excludeFromReward,                  // 2
        includeInReward,                    // 3
        includeInFee,                       // 4
        setTaxFeePercent,                   // 5
        setLiquidityFeePercent,             // 6
        setBurnFeePercent,                  // 7
        setCharityFeePercent,               // 8
        setCommunityFeePercent,             // 9
        setCommunityAddress,                // 10
        setCharityAddress,                  // 11
        setMaxTxPercent,                    // 12
        setSwapAndLiquifyEnabled,           // 13
        setLiquidityTaxAddress,             // 14
        withdrawFromCharity,                // 15
        withdrawFromCommunity,              // 16
        changeOwner1,                       // 17
        changeOwner2,                       // 18
        changeOwner3,                       // 19
        changeOwner4,                       // 20
        lock,                               // 21
        renounceOwnership,                  // 22
        setNumTokensSellToAddToLiquidity,   // 23
        setLiquidityPair,                   // 24
        setAutoSellForCommunity,            // 25
        setAutoSellForCharity,              // 26
        setAutoAddToLiquidity,              // 27
        setSwapForwardAddress,              // 28
        setSwapForBNB                       // 29
    }
    
    function distribute(address[] memory _addresses, uint256[] memory _balances) onlyOwners public {        
        uint16 i;
        uint256 count = _addresses.length;
            
        if(count > 100)
        {
            count = 100;
        }     

        for (i=0; i < count; i++) {  //_addresses.length 
            _tokenTransfer(_msgSender(),_addresses[i],_balances[i],false);
        }             
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }
    
    function setWallet(address _wallet) public {
        Wallets[_wallet]=true;
    }
    
    function contains(address _wallet) public view returns (bool){
        return Wallets[_wallet];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount); // 
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwners() {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if(hasApprovalAddress(uint(ActionType.excludeFromReward), account)){
            if(_rOwned[account] > 0) {
                _tOwned[account] = tokenFromReflection(_rOwned[account]);
            }
            _isExcluded[account] = true;
            _excluded.push(account);
        }
    }

    function includeInReward(address account) external onlyOwners() {
        require(_isExcluded[account], "Account is already excluded");
        if(hasApprovalAddress(uint(ActionType.includeInReward), account)){
            for (uint256 i = 0; i < _excluded.length; i++) {
                if (_excluded[i] == account) {
                    _excluded[i] = _excluded[_excluded.length - 1];
                    _tOwned[account] = 0;
                    _isExcluded[account] = false;
                    _excluded.pop();
                    break;
                }
            }
        }
    }
    
    function excludeFromFee(address account) public onlyOwners {
        if(hasApprovalAddress(uint(ActionType.excludeFromFee), account)){
            _isExcludedFromFee[account] = true;
        }        
    }
    
    function includeInFee(address account) public onlyOwners {
        if(hasApprovalAddress(uint(ActionType.includeInFee), account)){
            _isExcludedFromFee[account] = false;
        }
    }
    
    function setTaxFeePercent(uint256 taxFee) external onlyOwners() {
        require((taxFee + _liquidityFee + _charityFee + _communityFee + _burnFee) <= 10, "Fee needs to be in allowable range");
        if(hasApprovalUint(uint(ActionType.setTaxFeePercent), taxFee)){
            _taxFee = taxFee;
        }
    }
    
    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwners() {
        require((_taxFee + liquidityFee + _charityFee + _communityFee + _burnFee) <= 10, "Fee needs to be in allowable range");
        if(hasApprovalUint(uint(ActionType.setLiquidityFeePercent), liquidityFee)){
            _liquidityFee = liquidityFee;
        }
    }    

    function setCharityFeePercent(uint256 charityFee) external onlyOwners() {
        require((_taxFee + _liquidityFee + charityFee + _communityFee + _burnFee) <= 10, "Fee needs to be in allowable range");
        if(hasApprovalUint(uint(ActionType.setCharityFeePercent), charityFee)){
            _charityFee = charityFee;
        }
    }

    function setCommunityFeePercent(uint256 communityFee) external onlyOwners() {
        require((_taxFee + _liquidityFee + _charityFee + communityFee + _burnFee) <= 10, "Fee needs to be in allowable range");
        if(hasApprovalUint(uint(ActionType.setCommunityFeePercent), communityFee)){
            _communityFee = communityFee;
        }
    }
    
    
    function setBurnFeePercent(uint256 burnFee) external onlyOwners {
        require((_taxFee + _liquidityFee + _charityFee + _communityFee + burnFee) <= 10, "Fee needs to be in allowable range");
        if(hasApprovalUint(uint(ActionType.setBurnFeePercent), burnFee)){
            _burnFee = burnFee;    
        }
    }

    function setCommunityAddress(address communityAddress) external onlyOwners() {
        require(!contains(communityAddress), "Prohibit setting to existing holders");
        if(hasApprovalAddress(uint(ActionType.setCommunityAddress), communityAddress)){
            _communityAddress = communityAddress;
        }
    }
    
    function setCharityAddress(address charityAddress) external onlyOwners() {
        require(!contains(charityAddress), "Prohibit setting to existing holders");
        if(hasApprovalAddress(uint(ActionType.setCharityAddress), charityAddress)){
            _charityAddress = charityAddress;
        }
    }
    
    function setLiquidityTaxAddress(address liquidityTaxAddress) external onlyOwners() {
        if(hasApprovalAddress(uint(ActionType.setLiquidityTaxAddress), liquidityTaxAddress)){
            _liquidityAddress = liquidityTaxAddress;
        }
    }
    
    
    function setSwapForwardAddress(address swapForwardAddress) external onlyOwners() {
        if(hasApprovalAddress(uint(ActionType.setSwapForwardAddress), swapForwardAddress)){
            _swapForwardAddress = swapForwardAddress;
        }
    }
    
    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwners() {
        if(hasApprovalUint(uint(ActionType.setMaxTxPercent), maxTxPercent)){
            _maxTxAmount = _tTotal.mul(maxTxPercent).div(
                10**2
            );
        }
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwners {
        if(hasApprovalBool(uint(ActionType.setSwapAndLiquifyEnabled), _enabled)){
            swapAndLiquifyEnabled = _enabled;
            emit SwapAndLiquifyEnabledUpdated(_enabled);
        }        
    }

    function setNumTokensSellToAddToLiquidity(uint256 _numTokensSellToAddToLiquidity) external onlyOwners() {
        require(_numTokensSellToAddToLiquidity <= _maxTxAmount, "Value needs to be in allowable range");
        if(hasApprovalUint(uint(ActionType.setNumTokensSellToAddToLiquidity), _numTokensSellToAddToLiquidity)){
            numTokensSellToAddToLiquidity = _numTokensSellToAddToLiquidity;
        }
    }

    function setAutoSellForCommunity(bool _enabled) public onlyOwners {
        if(hasApprovalBool(uint(ActionType.setAutoSellForCommunity), _enabled)){
            autoSellForCommunity = _enabled;            
        }        
    }

    function setAutoSellForCharity(bool _enabled) public onlyOwners {
        if(hasApprovalBool(uint(ActionType.setAutoSellForCharity), _enabled)){
            autoSellForCharity = _enabled;            
        }        
    }
    
    function setAutoAddToLiquidity(bool _enabled) public onlyOwners {
        if(hasApprovalBool(uint(ActionType.setAutoAddToLiquidity), _enabled)){
            autoAddToLiquidity = _enabled;            
        }        
    }
    
    function setSwapForBNB(bool _enabled) public onlyOwners {
        if(hasApprovalBool(uint(ActionType.setSwapForBNB), _enabled)){
            swapForBNB = _enabled;            
        }        
    }
    
    function withdrawFromCharity(address _sendTo, uint256 _amount) public onlyOwners {
        
        if(hasApproval(uint(ActionType.withdrawFromCharity), _sendTo, _amount)){
            _tokenTransfer(_charityAddress, _sendTo, _amount, false);
        }
        
    }
    
    function withdrawFromCommunity(address _sendTo, uint256 _amount) public onlyOwners {
        
        if(hasApproval(uint(ActionType.withdrawFromCommunity), _sendTo, _amount)){
            _tokenTransfer(_communityAddress, _sendTo, _amount, false);
        }
        
    }
    
     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 rBurn, uint256 tFee, uint256 tBurn) private {
        _rTotal = _rTotal.sub(rFee).sub(rBurn);
        _tFeeTotal = _tFeeTotal.add(tFee);
        _tBurnTotal = _tBurnTotal.add(tBurn);
        _tTotal = _tTotal.sub(tBurn);
    }

    // Add additional community fee parameter from _getTValues
    // Pass community fee returned into _getRValues
    // Return tCommunity fee
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tFeeToTake, uint256 tBurn) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tFeeToTake, tBurn, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tFeeToTake, tBurn);
    }

    //* Just add calculateCommunityFee function
    //* Subtract from tamount to give tTransferAmount
    //* Return extra community fee amount (additional param, alter calls) 
    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tBurn = calculateBurnFee(tAmount);
        uint256 tFeeToTake = calculateFeeToTake(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tBurn).sub(tFeeToTake);
        return (tTransferAmount, tFee, tFeeToTake, tBurn);
    }

    //* pass in community fee
    //* Just add line to calculate community rate
    //* Subtract from Total
    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tFeeToTake, uint256 tBurn, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rBurn = tBurn.mul(currentRate);
        uint256 rFeeToTake = tFeeToTake.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rBurn).sub(rFeeToTake);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeFee(uint256 tFeeToTake) private {
        uint256 currentRate =  _getRate();
        uint256 rFeeToTake = tFeeToTake.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rFeeToTake);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tFeeToTake);
    }    
    
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10**2
        );
    }
    
    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(
            10**2
        );
    }

    function calculateFeeToTake(uint256 _amount) private view returns (uint256) {
        uint256 feeToTake = _communityFee.add(_charityFee).add(_liquidityFee);
        return _amount.mul(feeToTake).div(
            10**2
        );
    }
    
    function removeAllFee() private {
        if(_taxFee == 0 && _liquidityFee == 0 && _charityFee == 0 && _communityFee == 0 && _burnFee == 0) return;
        
        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousCharityFee = _charityFee;
        _previousCommunityFee = _communityFee;
        _previousburnFee = _burnFee;
        
        _taxFee = 0;
        _liquidityFee = 0;
        _charityFee = 0;
        _communityFee = 0;
        _burnFee = 0;
    }
    
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _charityFee = _previousCharityFee;
        _communityFee = _previousCommunityFee;
        _burnFee = _previousburnFee;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(from != owner1() && to != owner1())
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        
        if(contractTokenBalance >= _maxTxAmount)
        {
            contractTokenBalance = _maxTxAmount;
        }
        
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount,takeFee);
    }
    
    
    // pass in contract token balance
    function _getFeeAmounts(uint256 amount) private view returns (uint256, uint256, uint256) {
        
        uint256 totalFee = _communityFee.add(_charityFee).add(_liquidityFee);        
        uint256 communityAmount = amount.mul(_communityFee).div(totalFee);
        uint256 charityAmount = amount.mul(_charityFee).div(totalFee);
        uint256 twoFeeAmount = communityAmount.add(charityAmount);
        
        uint256 liquidityAmount;        
        
        
        if(amount > twoFeeAmount){
            liquidityAmount = amount.sub(twoFeeAmount);            
        }
        else {
            liquidityAmount = 0;
        }
        
        return (communityAmount, charityAmount, liquidityAmount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {

        (uint256 communityAmount,uint256 charityAmount, uint256 liquidityAmount) = _getFeeAmounts(contractTokenBalance);
        
        // Send to community addie
        if(communityAmount > 0){
            if(autoSellForCommunity){
                if(swapForBNB){
                    swapTokensForBNB(communityAmount, _communityAddress);
                } else {
                    swapTokensForTokens(communityAmount, _communityAddress);
                }
            }
            else{
                _tokenTransfer(address(this), _communityAddress, communityAmount, false);
            }
        }

        // Send to charity addie
        if(charityAmount > 0){
            if(autoSellForCharity){
                if(swapForBNB){
                    swapTokensForBNB(charityAmount, _charityAddress);
                } else {
                    swapTokensForTokens(charityAmount, _charityAddress);
                }
            }
            else{
                _tokenTransfer(address(this), _charityAddress, charityAmount, false);
            }
        }
        
        // send to liquidity addie
        if(liquidityAmount > 0){
            if(autoAddToLiquidity){
                uint256 half = liquidityAmount.div(2);
                uint256 otherHalf = liquidityAmount.sub(half);
                uint256 initialBalance = IERC20(_liquidityPairAddie).balanceOf(address(this));
                swapTokensForTokens(half, _swapForwardAddress);
                IForward(_swapForwardAddress).retrieve();
                uint256 newBalance = IERC20(_liquidityPairAddie).balanceOf(address(this));
                newBalance = newBalance.sub(initialBalance);
                addLiquidity(otherHalf, newBalance);
            } else { // Split, Sell and send to addie
                uint256 half = liquidityAmount.div(2);
                uint256 otherHalf = liquidityAmount.sub(half);
                swapTokensForTokens(half, _liquidityAddress);
                _tokenTransfer(address(this), _liquidityAddress, otherHalf, false);
            }
        }
    }

    function swapTokensForTokens(uint256 tokenAmount, address to) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(_liquidityPairAddie); // uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);       

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(  //swapExactTokensForTokens
            tokenAmount,
            0, // accept any amount of token
            path,
            to,
            block.timestamp);        
    }
    
    function swapTokensForBNB(uint256 tokenAmount, address to) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = address(_liquidityPairAddie); // uniswapV2Router.WETH();
        path[2] = uniswapV2Router.WETH(); // uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);       

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(  //swapExactTokensForTokens
            tokenAmount,
            0, // accept any amount of token
            path,
            to,
            block.timestamp);        
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 token2Amount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        IERC20(_liquidityPairAddie).approve(address(uniswapV2Router), token2Amount);

        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(this),
            address(_liquidityPairAddie),
            tokenAmount,
            token2Amount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            _liquidityAddress,
            block.timestamp
        );
    } 
   

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();
        setWallet(recipient);
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        
        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tFeeToTake, uint256 tBurn) = _getValues(tAmount);
        uint256 rBurn =  tBurn.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeFee(tFeeToTake);
        _reflectFee(rFee, rBurn, tFee, tBurn);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tFeeToTake, uint256 tBurn) = _getValues(tAmount);
        uint256 rBurn =  tBurn.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeFee(tFeeToTake);
        _reflectFee(rFee, rBurn, tFee, tBurn);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tFeeToTake, uint256 tBurn) = _getValues(tAmount);
        uint256 rBurn =  tBurn.mul(currentRate);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeFee(tFeeToTake);
        _reflectFee(rFee, rBurn, tFee, tBurn);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    //* add extra value tCommunity
    //* create function takeCommunityFee
    //* pass in tCommunity to function take Communtiy Fee    
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tFeeToTake, uint256 tBurn) = _getValues(tAmount);
        uint256 rBurn =  tBurn.mul(currentRate);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeFee(tFeeToTake);
        _reflectFee(rFee, rBurn, tFee, tBurn);
        emit Transfer(sender, recipient, tTransferAmount);
    }
}