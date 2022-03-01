Yo waddup.

HUH?!

| Test | Table |
|:----:| -----:|
| 1    | hi    |
| b    | yuh   |
| 999  | 54367 |

&lt;yowaddup[^hi]

![hi](/image/logo-mini.png)

h![a](/image/logo-mini.png)ello  tex$something cool \sin^{-1}(x)$ wah tex$$\alpha hi \begin{aligned}a & b \\ c & d\end{aligned}$$

tex[simple-grammar]

<span class="latex">
<svg width="96px" height="96px" viewBox="0 0 512 512" enable-background="new 0 0 512 512" xml:space="preserve">
<path d="M256,50C142.229,50,50,142.229,50,256c0,113.77,92.229,206,206,206c113.77,0,206-92.23,206-206
	C462,142.229,369.77,50,256,50z M256,417c-88.977,0-161-72.008-161-161c0-88.979,72.008-161,161-161c88.977,0,161,72.007,161,161
	C417,344.977,344.992,417,256,417z M382.816,265.785c1.711,0.297,2.961,1.781,2.961,3.518v0.093c0,1.72-1.223,3.188-2.914,3.505
	c-37.093,6.938-124.97,21.35-134.613,21.35c-13.808,0-25-11.192-25-25c0-9.832,14.79-104.675,21.618-143.081
	c0.274-1.542,1.615-2.669,3.181-2.669h0.008c1.709,0,3.164,1.243,3.431,2.932l18.933,119.904L382.816,265.785z"/>
</svg>
</span>

```rb
##
# Displays a date in a human readable format.
def render_date(date)
    day = date["day"]
    postfix = case day
        when 1, 21, 31 then "st"
        when 2, 22 then "nd"
        when 3, 23 then "rd"
        when 1..31 then "th"
        else "ii"
    end
    month = case date["month"]
        when 1 then "Jan"
        when 2 then "Feb"
        when 3 then "Mar"
        when 4 then "Apr"
        when 5 then "May"
        when 6 then "Jun"
        when 7 then "Jul"
        when 8 then "Aug"
        when 9 then "Sep"
        when 10 then "Oct"
        when 11 then "Nov"
        when 12 then "Dec"
        else "Kat"
    end
    year = date["year"]
    "#{day}#{postfix} #{month} #{year}"
end

##
# Displays a date in a monospaced format.
def render_date_mono(date)
    day_number = date["day"]
    day = case day_number
        when 1..9 then "0#{day_number}"
        when 10..31 then "#{day_number}"
        else "dd"
    end
    month_number = date["month"]
    month = case month_number
        when 1..9 then "0#{month_number}"
        when 10..12 then "#{month_number}"
        else "mm"
    end
    year_number = date["year"]
    year = case year_number
        when 1..9 then "000#{year_number}"
        when 10..99 then "00#{year_number}"
        when 100..999 then "0#{year_number}"
        when 1000..9999 then "#{year_number}"
        else "yyyy"
    end
    "#{day}-#{month}-#{year}"
end
<%= some erb %>
```

```cate
use lib::io

macro `&&`(condition, rhs)
  var lhs = condition
  if lhs
    lhs
  else
    rhs
  end
end macro

def const = 2r0110

def main(args : arr) : none
  io::print ...
    factorial(10) -- 3628800

  var result
  for::loop outer in [1, 2]
    for inner in [3, 4]
      if outer == 1 && false
        continue::loop
      end
      result = inner * outer
      break::loop
    end
  end for::loop

  print result
end

def factorial(n)
  if n <= 1
    1
  else
    factorial(n - 1) * n
  end if
end def

def raise_error() : int32 throws 'some_error
  throw 'some_error
end

def catch_errors()
  catch
    var a = try raise_error()
    var b = try raise_error()
    a + b
  end catch -- including this is entirely optional
            -- just gives some more checks at compile time
            -- as a sanity check
end
```

# References

[^hi]: This is a footnote.
