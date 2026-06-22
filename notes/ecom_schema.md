**A.Table Inventory**

| table | approx\_rows | What it stores | grain |
| :---- | :---- | :---- | :---- |
| orders | 40000 | It stores all the orders placed by all customers. | order details for each customer |
| order\_items | 81806 | Number of items in each. Where the order\_id  and variant\_id are foreign keys | Gives item detail within each order |
| customers | 10000 | Customer repository | Complete information about each customer |
| products | 4000 | Repository of all products sold by the company | Detailed description of each products |
| product\_variants | 12090 | Gives details of all variants within each product | Description of a variant within a product |
| sessions | 100000 | Complete unique session details for all customers and  device | Which device and customer logged into the ecom database |
| session\_events | 292903 | Give us complete idea about customer behaviour on the website. Watch out for lot of blanks in product\_id, variant\_id, quantity, unit\_price, order\_id | Gives us details of each event done by the customer on the app.  |
| attribution\_touches |  100000 | Complete marketing campaign details | Campaign details for one session completely |
| payment\_intents | 40000 | To understand how many payments went through | It tells us if particular transaction went through |
| payment\_transactions | 40034 | Idea of which payment gateway was used and why it failed | gateway /transaction and error code if failed |
| refunds | 260 | Complete refund history | Reason for the refund and status per transaction |
| return\_requests | 1603 | Details of all order returns | Status of a particular order |
| return\_items | 2004 | Gives the quantity of items and reason for each return | Reason , variant and quantity per return |
| shipments | 32089 | Unique Shipping details of each order | All shipping details of a single order |
| marketing campaigns | 100 | All campaign details including total cost | Details a particular campaign including cost of each campaign |
| attribution campaigns | 38405 | Advertising costs of all campaign | Ad cost per campaign |

**B.Per Column Notes**  
**a)Orders**

* order\_id \- primary key . it joins to order\_items, payment\_intents, refunds, return\_requests and shipments    
* order\_\_number \- it is a text data  type that is distinct and matches the number of rows  
*  created\_at \- time at which the order was created.

         Data type is timestamp with time zone

*  customer\_id \- acts as a foreign key to the customer table that ranges from 1 to 10000\. The data type is big int.  
* session\_id \- web session undertaken by the customer. the data type is uuid. acts as a foreign key to session table.  
* cart\_id \- the cart id for each customer session . data type is UUID, foreign key  
* price\_list\_id \-  the data type is big int, foreign key  
* status \-  Acts a foreign key to order\_status\_history. status of order. Delivery\[19979\], shipped\[7963\],paid\[3946\],packed\[3887\],cancelled\[2178\],placed\[1897\].  
* Subtotal-  order costs before tax. The data type is numeric. Range \[149\] to \[141593\]  
* discount-numeric,  discount on the product   
* Tax-tax on the product , numeric data type  
* Shipping\_fee- numeric, shipping cost on product,numeric type  
* Total- cost of order tax included, numeric data type  
* Payment\_status- confirm if payment has happened. Paid\[37822\], failed\[2178\],text type  
* shipping\_address\_id \- id of  shipping address of the product,foreign key,big int, nullable  
* Billing\_address\_id-foreign key, it links to a table with the billing address, big int type, nullable  
* Applied\_coupon\_id-big int type, coupon for discounts, nullable  
* Applied\_promo\_id- big int type, promo codes for discounts, nullable

**b)Customers**

* Customer\_id- primary key, identified each customer, big int.  
* Created\_at- time the account was created ,  timestamp with timezone  
* first\_name- first name of customer, text  
* last\_name \- last name of customer, text  
* dob- date of birth, date.  
* gender- gender of cust, text  
* primary\_email- email of cust, text  
* primary\_phone \- phone of the cust, text   
* Country- country of the cust,text, India\[7641\],United States\[1359\], Blanks\[700\],N/A\[200\]  
* State- state of each customer,Maharashtra\[1525\],Karnataka\[957\],Delhi\[831\],Tamil Nadu\[788\], Gujrat\[752\], Telangana\[547\], West Bengal\[526\], Uttar Pradesh\[504\], Rajasthan\[333\],Madhya Pradesh\[321\], Kerala\[270\],Texas\[241\],California\[220\],Punjab\[190\],Andhra Pradesh\[180\],Bihar\[171\],Haryana\[159\], chandigarh\[150\], washington\[123\], georgia\[117\],Oregon\[114\], Massachusetts\[114\], Florida\[112\],Illinois\[110\],New York\[106\], colorado\[102\], assam\[100\], chhattisgarh\[97\], odisha\[80\], uttarakhand\[80\], jharkhand\[80\]  
* City \- city of the customer, text, mumbai\[862\], delhi\[831\], bengaluru\[772\], hyderabad\[547\], chennai\[529\], kolkata\[526\], pune\[412\], ahmedabad\[340\], jaipur\[266\], surat\[262\],lucknow\[248\],vishakapatnam\[180\], bhopal\[179\], coimbatore\[175\], nagpur\[174\], kochi\[172\], patna\[171\], gurugram\[159\], noida\[158\], vadodara\[150\], chandigarh\[150\], indore\[142\], seattle\[123\], austin\[121\], Dallas\[120\], Atlanta\[117\], san franciso\[117\], boston\[114\], portland\[114\], miami\[112\], chicago\[110\], new york\[106\], san jose\[103\], denver\[102\], guwahati\[100\], varanasi\[98\], thiruvananthapuram\[98\], raipur\[97\], ludhiana\[97\], mysuru\[94\], amritsar\[93\], mangaluru\[91\], madurai\[84\], bhubaneshwar\[80\], dehradun\[80\], ranchi\[80\], nashik\[77\], udaipur\[67\]  
* Is\_email\_verified \- is email verified or not, boolean,true\[8489\],false\[1511\]  
* Is\_phone\_verified \- is it a verified phone, boolean,true\[7032\],false\[2968\]  
* Marketing\_opt\_in \- customer opting in for marketing communication,boolean, true\[5453\], false\[4547\]  
* lifecycle\_stage \- relationship with the business,text,active\[4869\],at\_risk\[3903\],new\[1200\],churned\[28\]  
* Acquistion\_channel \- how did they become a customer,  organic\[4023\], paid\[3490\], referral\[1192\],email\[708\],affiliate\[587\], text  
* source- communication source, text, linkedin\[1496\], affiliate\[1446\],direct\[1424\],newsletter\[1422\],meta\[1421\],youtube\[1396\],google\[1395\]  
* Utm\_campaign-campaign type, text,clearance\[1734\],retargeting\[1726\],new\_user\[1709\],diwali\_sale\[1638\],winter\_drop\[1601\],brand\_push\[1592\]  
* Utm\_medium- medium through which campaign was conducted, text,referral\[1790\],video\[1698\],cpc\[1642\],email\[1633\],  
  social\[1619\], none\[1618\]  
* utm\_source- source of campaign, text, affiliate\[1446\], direct\[1424\], newsletter\[1422\], meta\[1421\], youtube\[1396\], google\[1395\]

**c)Order\_item**

* Order\_id- foreign key to orders , reps each order,big int  
* Variant\_id- foreign key to product\_variants, reps variants for each product,big int  
* Qty- number of products,int  
* Unit\_price- price per unit, numeric  
* Line\_discount- discount for an individual item in the line, numeric  
* Line\_total-total price \- line discount,numeric

**d)Sessions-**

* session\_id-primary key for sessions, unique rep of each session,  
* Started\_at- time and day at which session started,timestamp with timezone  
* ended\_at-time and day at which session ended,timestamp with timezone  
* Customer\_id-foreign key, bigint, acts as a foreign key to customer\_id table  
* Anonymous\_id- denotes anonymous session on the website  
* Device\_id- device associated with each session, bigint,   
* Ip\_address- device address of computer,inet data type  
* Country- country of the ch, india\[86760\], United States\[13240\], text  
* Region- state of country where session happened, text,maharashtra\[15,352\]. karnataka\[9504\], delhi\[8374\],tamil nadu\[7735\],gujarat\[7657\],telangana\[5634\],west bengal\[5221\], uttar pradesh\[5094\], madhya pradesh\[3305\], rajasthan\[3275\],kerala\[2675\],texas\[2301\],california\[2224\],punjab\[1884\],andhra pradesh\[1832\],bihar\[1698\],haryana\[1626\],chandigarh\[1611\],washington\[1199\],oregon\[1120\],florida\[1120\],georgia\[1075\],new york\[1068\], massachusetts\[1059\],Illinois\[1052\],colorado\[1022\],assam\[914\],chattisgarh\[893\],uttarakhand\[860\],jharkhand\[828\],odisha\[788\]  
* city- city of where login happened, dallas\[1151\], austin\[1150\],miami\[1120\],portland\[1120\],atlanta\[1075\],newyork\[1068\],boston\[1059\],chicago\[1052\],san jose\[1037\],denver\[1022\],varanasi\[973\],thiruvananthapuram\[950\],ludhiana\[944\],mysuru\[941\],amritsar\[940\],guwahati\[914\],raipur\[893\],mangaluru\[893\],dehradun\[860\],ranchi\[828\],nashik\[827\], madurai\[804\],bhubaneshwar\[788\],udaipur\[702\],text  
* Landing\_page- what section of website did customer log into,text  
* Referrer- origin of customer, text, direct\[34758\], google\[24977\], meta\[18269\],youtube\[6980\],newsletter\[6045\],linkedin\[5057\],affiliate\_site\[3914\]
**e)attribution\_touches**

* Touch\_id- primary key, unique identifier to a specific customer interaction, big int  
* session\_id- foreign key connecting to sessions table,uuid  
* touched\_at- time when interaction happened,timestamp with timezone,   
* utm\_source-source of interaction, text, meta\[14475\],affiliate\[14437\]\],youtube\[14358\],google\[14259\],newsletter\[14078\],direct\[13992\]  
* utm\_medium-marketing channel, none\[16611\],video\[16573\]  
* utm\_campaign- specialist initiative,retargeting\[16865\],brand\_push\[16705\],clearance\[16675\],diwali\_sale\[16625\],new\_user\[16621\],winter\_drop\[16509\]  
* utm\_term- identify keywords for paid ad campaigns,text, blanks\[33342\],skincare\[16746\],sale\[16741\],shoes\[16717\],headphones\[16454\]  
* Utm\_content-exact ad clicked by customer to reach website,text,banner\_b\[20359\],blank\[20019\],video\_1\[200000\],banner\_a\[19967\],carousel\[19655\]  
* channel-ad platform used,text,organic\[39924\],paid\[34905\],referral\[12146\],email\[6995\],affiliate\[6030\]  
* referrer-exact url  that drives traffic,text

**f) payment\_intent-**  

* payment\_intent\_id-primary key that represents the payment lifecycle for each order,bigint  
* order\_id-connects to the order table,bigint  
* created\_at- when was the transaction started,timestamp with timezone  
* payment\_method\_id-what type of payment method was used for the transaction,bigint  
* amount- amount for the transaction,numeric  
* status- did it succeed?,text,succeeded\[38134\],failed\[1866\]

**C.Verified relationships**

| parent table | child table | Join column | cardinality | orphan count |
| :---- | :---- | :---- | :---- | :---- |
| order | order\_item | order\_id | 1:M | 0 |
| customers | orders | customer\_id | 1:M | 0 |
| product\_variants | order\_items | variant\_id | 1:M | 0 |
| products | product\_variants | product\_id | 1:M | 0 |
| categories | products | category\_id | 1:M | 0 |
| customers | sessions | customer\_id | 1:M | 34751 |
| sessions | attribution\_touches | session\_id | 1:M | 0 |
| orders | refunds | order\_id | 1:M | 0 |
| orders | return\_requests | order\_id | 1:M | 0 |

**D. ER Diagram**  
erDiagram  
    customers          ||--o{ orders : places  
    orders             ||--|{ order\_items : contains  
    order\_items        }o--|| product\_variants : ships  
    product\_variants   }o--|| products : sku\_of  
    products           }o--|| categories : in  
    orders             ||--o{ payment\_intents : pays\_via  
    payment\_intents    ||--o{ payment\_transactions : attempts  
    orders             ||--o{ refunds : may\_have  
    orders             ||--o{ return\_requests : may\_return  
    return\_requests    ||--|{ return\_items : with  
    orders             ||--o{ shipments : ships  
    customers          ||--o{ sessions : starts  
    sessions           ||--o{ session\_events : logs  
    sessions           ||--o{ attribution\_touches : has  
    attribution\_touches }o--o| attribution\_campaigns : maps\_via\_bridge  
    attribution\_campaigns }o--|| marketing\_campaigns : refs

**E.Five things that surprised me**

* sessions → customers has around 34751 orphan pairs.