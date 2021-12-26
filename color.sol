//  SPDX-License-Identifier: GPL-3.0;

pragma solidity >= 0.7.0 < 0.9.0;

struct Customer{    /*info about the customer*/
    address customer;   /*ethereum address of customer*/
    string customerAddress;     /*house address of customer*/
    string day;                 /*day the customer would like the cleaning to be done*/
    string time;                /*time the customer would like the cleaning to be done*/
    uint noOfRooms;             /*number of rooms requireing cleaning*/
    bool jobDone;
    bool paid;
}
struct Owner{                /*owner information*/
    string name;            /*name of the cleaning service*/
    uint pricePerRoom;      /*price of cleaning a room*/
    uint noOfCustomers;     /*keeps track of the number of customers*/
    address payable owner;      /*the address of the cleaning service to receive the payment*/
    uint noOfBookings;      /*sets the number of bookings*/
    string[] reviews;       /*list of reviews*/
    uint noOfReviews;
    mapping(address=>Customer) customers;       /*nmaps the addresses of customers*/
}


// the contract
contract CleaningService{

    address payable publisher;      /*sets the contract deployer*/
    uint noOfShops;                /*sets the no of stores using this contract*/
    uint bookings;                  /*helps get the number of people using this contract service*/
    mapping(address=>Owner) public owners;    /*maps the owners address to the list of shops*/
    mapping(address=>bool) public checkShop;  /*checks if shop already exists*/

    event ServiceBooked(Customer,string name); /*alerts the shop that its service has been booked*/
    event CustomerPaid(bool);
    constructor() {
        publisher = payable(msg.sender);        /*sets the publicsher of the contract*/
    }
// the function below helps the entity set up shop
    function setUpShop(string memory companyName,uint price_) public payable{
        require(checkShop[msg.sender] != true,'you already have an account');

        noOfShops++;            /*keeps track of the number of shops so far*/
        Owner storage c = owners[msg.sender];   /*creates an instance of owner struct*/
        checkShop[msg.sender] = true;         /*registers the shop into the database*/
        c.name = companyName;           /*sets the name of the company*/
        c.owner = payable(msg.sender);       /*sets the address of the shop to receive payment*/
        c.pricePerRoom = price_;             /*sets the charged price*/
        
    }
    // this function sets up the services rendered

    
    //  this helps books services
    function bookService(
        string memory customerAddress_,
        string memory day_,
        string memory time_,
        address ownerAddress,uint noOfRooms_) 
        public payable {
        
        Customer storage c = owners[ownerAddress].customers[msg.sender];     /*creates a customer instance*/
        c.customer = msg.sender;     
        c.customerAddress = customerAddress_;        
        c.day = day_;
        c.time = time_;
        c.noOfRooms = noOfRooms_;
        emit ServiceBooked(c,owners[ownerAddress].name);
    }

    function checkOut(address shop) public returns(uint total){
        uint price = owners[shop].pricePerRoom;
        uint customerNoOfRooms = owners[shop].customers[msg.sender].noOfRooms;

        total = price * customerNoOfRooms;  
         Customer storage c = owners[shop].customers[msg.sender];   
         c.paid = true;
         emit CustomerPaid(c.paid);
         return total;
  
    }

    //  this function aids in paying the cost f service
    function payFee(address shop) public payable  {
        uint total = this.checkOut(shop);
        require (msg.value >= total);
        uint share = total / 20;
        uint fee = total - share;
        owners[shop].owner.transfer(fee);
        publisher.transfer(share);
    }

    // this helps the shop owner check the customer's details
    function getCustomer(address customerAddress_)public view returns(Customer memory a){
       return owners[msg.sender].customers[customerAddress_];
    }
    function reviews(string memory review,address shop) public  {
    owners[shop].reviews.push(review); 
    }

}

