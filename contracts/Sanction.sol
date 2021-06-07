contract Sanction is Context {

    uint private approveFunction;
    address private approveAddress;
    uint256 private approveUint256;
    bool private approveBool;
    
    uint256 private _lockTime;

    uint private owner1Approval = 0;
    uint private owner2Approval = 0;
    uint private owner3Approval = 0;
    uint private owner4Approval = 0;

    uint256 private _requiredVotes = 3;

    address private _owner1;
    address private _owner2;
    address private _owner3;
    address private _owner4;

    address private _previousOwner1;
    address private _previousOwner2;
    address private _previousOwner3;
    address private _previousOwner4;
    
    // internal action indexes
    // set arbitriraly high so as not to affect main contract usage
    uint private _changeOwner1 = 94;
    uint private _changeOwner2 = 95;            
    uint private _changeOwner3 = 96;            
    uint private _changeOwner4 = 97;             
    uint private _lock = 98;                    
    uint private _renounceOwnership = 99;
    uint private _changeRequiredVotes = 100;

    constructor (address owner1, address owner2, address owner3, address owner4, uint256 requiredVotes) internal {
        _owner1 = owner1;
        _owner2 = owner2;
        _owner3 = owner3;
        _owner4 = owner4;
        _requiredVotes = requiredVotes;
    }

    function owner1() public view returns (address) {
        return _owner1;
    }
    function owner2() public view returns (address) {
        return _owner2;
    }
    function owner3() public view returns (address) {
        return _owner3;
    }
    function owner4() public view returns (address) {
        return _owner4;
    }

    modifier onlyOwners() {
        require(_msgSender() == _owner1 || _msgSender() == _owner2 || _msgSender() == _owner3 || _msgSender() == _owner4, "only owners");
        _;
    }
    
    function getApproveFunction() public view onlyOwners returns (uint) {
        return approveFunction;
    }
    
    function getApproveUint256() public view onlyOwners returns (uint256) {
        return approveUint256;
    }

    function getApproveAddress() public view onlyOwners returns (address) {
        return approveAddress;
    }

    function getApproveBool() public view onlyOwners returns (bool) {
        return approveBool;
    }
    

    function hasApproval(uint action, address value1, uint256 value2) internal returns (bool) {
        bool result = false;
        bool approved = (approveFunction == uint(action) && approveAddress == value1 && approveUint256 == value2);
        uint voteCount = owner1Approval + owner2Approval + owner3Approval + owner4Approval;
        
        if(approved && voteCount >= _requiredVotes){
            result = true;
            resetApproval();
        }
        return result;
    }
    
    function hasApprovalAddress(uint action, address value) internal returns (bool) {
        bool result = false;
        bool approved = (approveFunction == uint(action) && approveAddress == value);
        uint voteCount = owner1Approval + owner2Approval + owner3Approval + owner4Approval;
        if(approved && voteCount >= _requiredVotes)
        {
            result = true;
            resetApproval();
        }
        return result;
    }

    function hasApprovalUint(uint action, uint256 value) internal returns (bool) {
        bool result = false;
        bool approved = (approveFunction == uint(action) && approveUint256 == value);
        uint voteCount = owner1Approval + owner2Approval + owner3Approval + owner4Approval;
        
        if(approved && voteCount >= _requiredVotes)
        {
            result = true;
            resetApproval();
        }
        return result;
    }
    
    function hasApprovalBool(uint action, bool value) internal returns (bool) {
        bool result = false;
        bool approved = (approveFunction == uint(action) && approveBool == value);
        uint voteCount = owner1Approval + owner2Approval + owner3Approval + owner4Approval;
        if(approved && voteCount >= _requiredVotes)
        {
            result = true;
            resetApproval();
        }
        return result;
    }

    function confirmVote() private {
        if(_msgSender() == _owner1){            
            owner1Approval = 1;
        }
        if(_msgSender() == _owner2){
            owner2Approval = 1;
        }
        if(_msgSender() == _owner3){
            owner3Approval = 1;
        }
        if(_msgSender() == _owner4){
            owner4Approval = 1;
        }
    }

    function approveChangeAddress(uint action, address value) public onlyOwners {
        if(approveFunction == 0){ // first vote
            approveFunction = action;
            approveAddress = value;
            confirmVote();
        } else if (approveFunction == action && approveAddress == value){ //2nd & 3rd vote
            confirmVote();
        }          
    }

    function approveChangeUint(uint action, uint256 value) public onlyOwners {
        if(approveFunction == 0){
            approveFunction = action;
            approveUint256 = value;
            confirmVote();
        } else if (approveFunction == action && approveUint256 == value){
            confirmVote();
        }          
    }
    
    function approveChangeAddressUint(uint action, address value1, uint256 value2) public onlyOwners {
        if(approveFunction == 0){
            approveFunction = action;
            approveAddress = value1;
            approveUint256 = value2;
            confirmVote();
        } else if (approveFunction == action && approveAddress == value1 && approveUint256 == value2){
            confirmVote();
        }          
    }

    function approveChangeBool(uint action, bool value) public onlyOwners {
        if(approveFunction == 0){
            approveFunction = action;
            approveBool = value;
            confirmVote();
        } else if (approveFunction == action && approveBool == value){
            confirmVote();
        }          
    }

    function resetApproval() public onlyOwners {
        owner1Approval = 0;
        owner2Approval = 0;
        owner3Approval = 0;
        owner4Approval = 0;
        approveFunction = 0;
    }

    function renounceOwnership(bool agree) public onlyOwners {
        if(hasApprovalBool(_renounceOwnership, agree)){
            _owner1 = address(0);
            _owner2 = address(0);
            _owner3 = address(0);
            _owner4 = address(0);
        }
    }    

    function changeOwner1(address newOwner) public onlyOwners {
        if(hasApprovalAddress(_changeOwner1, newOwner)){
            _owner1 = newOwner;
        }           
    }

    function changeOwner2(address newOwner) public onlyOwners {
        if(hasApprovalAddress(_changeOwner2, newOwner)){
            _owner2 = newOwner;
        }        
    }

    function changeOwner3(address newOwner) public onlyOwners {
        if(hasApprovalAddress(_changeOwner3, newOwner)){
            _owner3 = newOwner;
        }        
    }
    
    function changeOwner4(address newOwner) public onlyOwners {
        if(hasApprovalAddress(_changeOwner4, newOwner)){
            _owner4 = newOwner;
        }  
    }

    function changeRequiredVotes(uint256 votes) public onlyOwners {
        if(hasApprovalUint(_changeRequiredVotes, votes) && votes <= 4){
            _requiredVotes = votes;
        }  
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    // Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public onlyOwners {

        if(hasApprovalUint(_lock, time)){
            _previousOwner1 = _owner1;
            _previousOwner2 = _owner2;
            _previousOwner3 = _owner3;
            _previousOwner4 = _owner4;
            _owner1 = address(0);
            _owner2 = address(0);
            _owner3 = address(0);
            _owner4 = address(0);
            _lockTime = now + time;
        }
    }
    
    // Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public {
        require(_previousOwner1 == msg.sender || _previousOwner2 == msg.sender || _previousOwner3 == msg.sender || _previousOwner4 == msg.sender , "!Permissions");
        require(now > _lockTime , "Contract locked until 7 days");        
        _owner1 = _previousOwner1;
        _owner2 = _previousOwner2;
        _owner3 = _previousOwner3;
        _owner4 = _previousOwner4;
    }
}
