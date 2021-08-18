--Select the database
use KaggleDataset

create schema Sales_1
go

--A. Know the contain of Table
select * from Sales_1.Supermarket

--B. Simple Aggregate
  --B.1 Count transaction by product and gender
select [Product line], Gender, COUNT([Invoice ID]) as TotalTransaction
from Sales_1.Supermarket
group by [Product line], Gender
order by [Product line],TotalTransaction

 --B.2 Get top sales 10 product by city
select top 10 [Product Line], City, sum(Quantity) as TotalQty from  Sales_1.Supermarket
 group by City, [Product line]
 order by 3 desc

  --B.3 Get city, product line and Total Quantity that has above average rating value 
Select city,[Product line], avg(Rating) Rating, sum(Quantity) TotalQty from Sales_1.Supermarket
 where Rating >= (select avg(Rating) from Sales_1.Supermarket)
 group by city,[Product line], Rating
 order by Rating desc, [Product line] asc
  
  --B.4 Get Minimal and Maximal Total Sales by City and Product line
select City,[Product line], MIN([Unit price]*Quantity) MinSales
 , MAX([Unit Price]*Quantity)as MaxSales from Sales_1.Supermarket
 group by City, [Product line]
 order by 1,2

  --B.5 Get Total Sales by city
Select City, SUM([Unit Price] * Quantity) as TotalSales from Sales_1.Supermarket
 group by City
 order by TotalSales desc

---C. Select with conditional Column
 --C.1 Get total sales by Product Line in Yangon City
Select [Product Line],
 SUM([Unit Price] * Quantity) as TotalSales
 from Sales_1.Supermarket
 --or
 --Where City = 'Yangon'  
where City in ('Yangon')
group by [Product Line]
order by TotalSales desc

---D. Work with View table 
 --D.1 Create view table to add Calculate Column
Create view CalColumnView
as
Select ModifiedDate, Branch, City, [Customer type], Gender, [Product line],[Unit price],Quantity,
       [Unit Price] * Quantity TotalSales,
       [Unit Price] * Quantity * 0.05 'Tax5%',
      ([Unit Price] * [Quantity] * 0.05) + ([Unit Price] * [Quantity]) PaymentTotal
from Sales_1.Supermarket
  
  --D.2 Test for the view
select * from CalColumnView

  --D.3 Get Total and Average sales by MonthSales, City, and Product line from the view table
select MONTH(ModifiedDate) MonthSales, City,[Product line], 
SUM(TotalSales) TotalSales, round(AVG(TotalSales),3)MeanSales
from CalColumnView
group by MONTH(ModifiedDate), City, [Product line]
order by City

--E. Calculate total sales with date
 --E.1 Know the total year and total month
select distinct YEAR(ModifiedDate) 'Year' from Sales_1.Supermarket  /*The data just has one year*/

select count(distinct Month(ModifiedDate)) 'Total Month' from Sales_1.Supermarket
 order by [Total Month]

 --E.2 Sum TotalSales by Date and Add a cummulative column
select ModifiedDate
,SUM(TotalSales) as TotalSales
,SUM(sum(TotalSales)) over (order by ModifiedDate) as CumTotal 
from CalColumnView
group by ModifiedDate
  

---F. Create Stored Procedures with Branch or City Value as Parameter (1 Parameter)
 --F.1 For the first step, Know the Value of Branch and City
select distinct Branch,City  from Sales_1.Supermarket
order by Branch 

/*One Branch for one City or it can concluse that one branch represent one city*/
 --F.2 Create Store Procedure for Calculate Total Sales by Date, Product Line, and City with Branch as parameter (1 parameter)
Create Procedure CumInCity @Branch varchar (20)
as
select ModifiedDate,City,[Product line],SUM(TotalSales) TotalSales,
round(sum(SUM(TotalSales)) over (order by ModifiedDate) ,2) as CumDateTotal
from CalColumnView
where Branch = @Branch
group by ModifiedDate, City, [Product line]
order by [Product line],ModifiedDate

	/*Test For the Stored Procedures*/
exec CumInCity @Branch = 'c'

 --F.3 Create Store Procedure for Calculate Total Sales by Month, Product Line, and City with Branch as parameter (1 parameter)
Create Procedure CumInCityPerMonth @Branch varchar (1)
as
select Month(ModifiedDate)'Month',City,[Product line],SUM(TotalSales) TotalSales,
round(sum(SUM(TotalSales)) over (order by Month(ModifiedDate)) ,2) as CumDateTotal
from CalColumnView
where Branch = @Branch
group by Month(ModifiedDate), City, [Product line]
order by [Product line],Month(ModifiedDate)

	/*Test For the Stored Procedures*/
exec CumInCityPerMonth @Branch ='C'

 --F.4 Create Store Procedure for Calculate Total Sales by Date, Product line, and City with Branch and Product line as parameter (2 parameters)
create Procedure CumDateProduct
@Branch varchar (1),
@Product varchar(100)
as
select ModifiedDate,City,[Product line],SUM(TotalSales) TotalSales,
round(sum(SUM(TotalSales)) over (order by ModifiedDate) ,2) as CumDateTotal
from CalColumnView
where Branch = @Branch and [Product line]=@Product
group by ModifiedDate, City, [Product line]
order by ModifiedDate

	/*Test For the Stored Procedures*/
exec CumDateProduct @Branch='A', @Product= 'Fashion accessories'

 --F.2 Create Store Procedure for Calculate Total Sales by Date, Product line, and City with Branch and Product line as parameter (2 parameters)
create Procedure CumMonthProduct 
@Branch varchar (20),
@Product varchar (100)
as
select Month(ModifiedDate)'Month',City,[Product line],SUM(TotalSales) TotalSales,
round(sum(SUM(TotalSales)) over (order by Month(ModifiedDate)) ,2) as CumDateTotal
from CalColumnView
where Branch = @Branch and [Product line]=@Product
group by Month(ModifiedDate), City, [Product line]
order by  Month(ModifiedDate)

exec CumMonthProduct @Branch='B', @Product = 'Sports and travel'