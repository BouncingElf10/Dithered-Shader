// All credits to Patapom
// https://www.shadertoy.com/view/Mlt3z8
float B2( vec2 _P ) {
    //    return ((_P.y << 1) + _P.x + 1) & 3;	<= This would fare much better than modulos and floors :(
    return mod( 2.0*_P.y + _P.x + 1.0, 4.0 );
}

float B4( vec2 _P ) {
    vec2	P1 = mod( _P, 2.0 );					// (P >> 0) & 1
    vec2	P2 = floor( 0.5 * mod( _P, 4.0 ) );		// (P >> 1) & 1
    return 4.0*B2(P1) + B2(P2);
}

float B8( vec2 _P ) {
    vec2	P1 = mod( _P, 2.0 );					// (P >> 0) & 1
    vec2	P2 = floor( 0.5 * mod( _P, 4.0 ) );		// (P >> 1) & 1
    vec2	P4 = floor( 0.25 * mod( _P, 8.0 ) );	// (P >> 2) & 1
    return 4.0*(4.0*B2(P1) + B2(P2)) + B2(P4);
}

float B16( vec2 _P ) {
    vec2	P1 = mod( _P, 2.0 );					// (P >> 0) & 1
    vec2	P2 = floor( 0.5 * mod( _P, 4.0 ) );		// (P >> 1) & 1
    vec2	P4 = floor( 0.25 * mod( _P, 8.0 ) );	// (P >> 2) & 1
    vec2	P8 = floor( 0.125 * mod( _P, 16.0 ) );	// (P >> 3) & 1
    return 4.0*(4.0*(4.0*B2(P1) + B2(P2)) + B2(P4)) + B2(P8);
}

float B32(vec2 _P) {
    vec2    P1 = mod(_P, 2.0);                   // (P >> 0) & 1
    vec2    P2 = floor(0.5 * mod(_P, 4.0));     // (P >> 1) & 1
    vec2    P4 = floor(0.25 * mod(_P, 8.0));    // (P >> 2) & 1
    vec2    P8 = floor(0.125 * mod(_P, 16.0));  // (P >> 3) & 1
    vec2    P16 = floor(0.0625 * mod(_P, 32.0));// (P >> 4) & 1
    return 4.0 * (4.0 * (4.0 * (4.0 * B2(P1) + B2(P2)) + B2(P4)) + B2(P8)) + B2(P16);
}
