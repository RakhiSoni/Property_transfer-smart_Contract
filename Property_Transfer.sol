pragma solidity ^0.4.18;

//***********************************No intermediary*******************************************//
//...................................Proprty Transfer..........................................//
//.......................A decentralized method to transfer the property.......................//


//***********************************Benifits**************************************************//
//1. No central authority.
//2. less time consuming.
//3. less expenses.
//4. No document management burden.
//5. No possible fraudulents.

//................................smart contract begins........................................//

contract PropertyTransfer {


    address public owner;	

    uint256 public totalNoOfProperty;	
    
    function PropertyTransfer() public {
        owner = msg.sender; // only owner can transfer the property
    }

    modifier onlyOwner() {
        require(msg.sender == owner); // sender is the owner
        _;
    }

// Property Details

    struct PropertyDetails {
		string p_name;                 
		string p_street;                        
		string p_city;
		string p_state;
		string p_zip;
		string p_country;
        uint256 propertyCount;
        bool isSold;
    }					

//property mapping with owner					
    mapping(address => mapping(uint256=>PropertyDetails)) public propertyowner; 
																		
    mapping(address => uint256) propertyCountPerOwner;	// per owner property count regards to individual	

// events for property alloted and Property Transferred

    event PropertyAlloted(address indexed _verifiedOwner, uint256 indexed  _totalNoOfPropertyCurrently, string _nameOfProperty, string _msg);

    event PropertyTransferred(address indexed _from, address indexed _to, string _propertyName, string _msg);

  
//******* per address property count*******//  

    function getPropertyCountOfAnyAddress(address _ownerAddress) public constant returns (uint256){
        uint count=0;
        for(uint i =0; i<propertyCountPerOwner[_ownerAddress];i++){
            if(propertyowner[_ownerAddress][i].isSold != true)
            count++;
        }
        return count;
    }

//******** Property allocation to the new owner with a varification first**********//

    function allotProperty(address _verifiedOwner, string _propertyName) public onlyOwner {
        propertyowner[_verifiedOwner][propertyCountPerOwner[_verifiedOwner]++].p_name = _propertyName;
        totalNoOfProperty++;
        PropertyAlloted(_verifiedOwner,propertyCountPerOwner[_verifiedOwner], _propertyName, "property allotted successfully");
    }

// ************ check the owner of the property using property name as unique name and by putting address to check*********//    

    function isOwner(address _checkOwnerAddress, string _propertyName) public constant returns (uint){
        uint i ;
        bool flag ;
        for(i=0 ; i<propertyCountPerOwner[_checkOwnerAddress]; i++){
            if(propertyowner[_checkOwnerAddress][i].isSold == true){
                break;
            }
         flag = stringsEqual(propertyowner[_checkOwnerAddress][i].p_name,_propertyName);
            if(flag == true){
                break;
            }
        }
        if(flag == true){
            return i;
        }
        else {
            return 999999999;
        }
    }

   
    function stringsEqual(string a1, string a2) private constant returns (bool) {
        if(sha3(a1) == sha3(a2))
            return true;
        else
            return false;
    }

   
//********************** transfer of property **********************************//
//**********************this should be called by the varification only**********//


    function transferProperty (address _to, string _propertyName) public returns (bool ,  uint )
    {
        uint256 checkOwner = isOwner(msg.sender, _propertyName);
        bool flag;

        if(checkOwner != 999999999 && propertyowner[msg.sender][checkOwner].isSold == false){
            
            propertyowner[msg.sender][checkOwner].isSold = true;
            propertyowner[msg.sender][checkOwner].p_name = "Sold";
            propertyowner[_to][propertyCountPerOwner[_to]++].p_name = _propertyName;
            flag = true;
            PropertyTransferred(msg.sender , _to, _propertyName, "Owner has been changed." );
        }
        else {
            flag = false;
            PropertyTransferred(msg.sender , _to, _propertyName, " doesn't own the property." );
        }
        return (flag, checkOwner);
    }
}

//................................smart contract ends..........................................//