//##! 0 Empty file has no unmatched regions

//##! 0 Adjacent and nested regions
//#region
//#endregion
// #region
// #region
// #endregion
// #endregion

//##! 1 Missing end marker
// #region

//##! 1 Missing start marker
// #endregion

//##! 1 Equal counts in the wrong order report the first unmatched end
// #endregion
// #region

//##! 1 Report only the first unclosed start marker
// #region
// #region
// #region
// #endregion

//##! 1 Report only the first unmatched end marker
// #endregion
// #region
// #endregion
// #endregion

//##! 0 Whitespace around markers
//	 #region 	
//  	#endregion	 

//##! 0 Marker names must be exact and case sensitive
// #regions
// #endregion_extra
// #REGION
// #EndRegion
// #regionSuffix
// ordinary text #endregion
/// #region

//##! 0 Only single line comments count
/* #region */
/*
// #endregion
*/
function region_strings(): void {
  $_ = "// #region";
  $_ = '// #endregion';
}

//##! 1 A block comment cannot close a region
// #region
/* #endregion */

//##! 0 Trailing comments are markers too
function inline_regions(): void { //#region
} //#endregion

//##! 0 Region nesting is independent of Hack braces
// #region
function spanning_region(): void {
  // #endregion
}

//##! 0 Named regions
// #region Helpers
// #region Nested helpers
// #endregion Nested helpers
// #endregion Helpers

//##! 1 Unclosed named region
// #region Helpers

//##! 1 Completed regions do not leave stale opening locations
// #region Closed
// #region Also closed
// #endregion
// #endregion
// #region First unclosed
// #region Later unclosed
