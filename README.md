# A SQL Script to generate a 4-4-5 Mon-Sun calendar table

(originally published on my blog on 2011-12-09, but originally created in 2006)

In a previous life, I did A LOT of BI reporting, and everything we did was based on the company’s 4-4-5 fiscal calendar, and a Mon-Sun work week.  Adding to the fun was the mutant Julian style date JD Edwards uses internally.  This system violated every known calendaring convention, but “that’s how it’s set up in JDE”, and if you’re a JD Edwards shop, you know that argument renders all others invalid.  Oh yeah, the fiscal year started on a different day every year.

To make our lives easier and our apps and reports more performant, we utilized calendar tables.  Problem is, every couple years, we had to add more dates to the tables.  When this duty fell onto me, rather than being The Last Person, and spend all day fiddling with Excel and a subsequent import, I spent part of a day writing a simple script that can be run whenever necessary to add more dates.

Because we were integrating information from a number of systems (WMS, TMS, LMS and payroll, notably), all with their own equally mutant calendaring systems, we have a fairly wide table with all kinds of date indicators in it.  This script is kind of a recursion hell, but it needed to be in order to iterate all of the output columns correctly.

Update 2020-09-15

This is a wacky calendar for sure, there are other ways to deal with leap years, pull requests are welcome!  I'd love to have a set of useful calendars here.