*Graphing exercises
clear all

*Set working directory
gl path "<working directory>"
cd "$path"

*===============================================================================
*Graph #1
set obs 1000000
gen y = runiform(-20,20)
sort y

scalar a1 = 5
scalar a2 = 10

*Demand (LD)
gen x1 = (-1*y) + a1  // LD1 
//drop if (x1>1)
gen x2 = (-1*y) + a2  // LD2
// drop if x2>1

*Supply (LS)
gen x3 = y + 1

*Solve the simultaneous non-linear equations
mata
mata clear
void function myfun(real colvector y, real colvector x) 
{
	x[1] = (-1*y[2]) + 5
	x[2] = y[1] + 1
}  
S = solvenl_init()
solvenl_init_evaluator(S, &myfun())
solvenl_init_type(S, "fixedpoint")
solvenl_init_technique(S, "dampedgaussseidel")
solvenl_init_numeq(S, 2)
solvenl_init_startingvals(S, J(2, 1, 1))
solvenl_init_iter_log(S, "off")
equi_old = solvenl_solve(S)
equi_old = solvenl_result_values(S)
equi_old
 
st_numscalar("y1star", equi_old[1])
st_numscalar("x1star", equi_old[2])
end

dis y1star 
dis x1star

mata
void function myfun(real colvector x, real colvector y) 
{
	x[1] = (-1*y[2]) + 10
	x[2] = y[1] + 1
}
    
S = solvenl_init()
solvenl_init_evaluator(S, &myfun())
solvenl_init_type(S, "fixedpoint")
solvenl_init_technique(S, "dampedgaussseidel")
solvenl_init_numeq(S, 2)
solvenl_init_startingvals(S, J(2, 1, 1))
solvenl_init_iter_log(S, "off")
equi_new = solvenl_solve(S)
equi_new = solvenl_result_values(S)
equi_new

st_numscalar("y2star", equi_new[1])
st_numscalar("x2star", equi_new[2])
end

scalar y2star = 4.5
scalar x2star = 5.5

*Plot the graphs
graph twoway (line y x1 , legend(label(1 "LD1")))   ///
             (line y x2 , legend(label(2 "LD2")))   ///
             (line y x3 , legend(label(3 "LS" )))   ///
			, ytitle(price)                         ///  
			  xtitle(quantity)                      ///
			  yline(2 4.5, lwidth(0.2) lcolor(gs15)) /// 
			  ylabel(2 4.5)                          ///
			  xline(3 5.5, lwidth(0.2) lcolor(gs15)) /// 
			  xlabel(3 5.5)                          ///
			  legend(col(3))
			  name(graph_1, replace)

graph export "graph_1.png", name(graph_1) as(png) replace

*============================= CODE ENDS HERE ==================================
