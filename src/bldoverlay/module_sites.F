
C*************************************************************************
C
C  MODULE: defines site data
C             
C*************************************************************************
      MODULE SITE_DATA

      Type METSITE
        Integer        :: siteid
        Real           :: latitude
        Real           :: longitude
        End Type METSITE


      Integer         :: NSITES
      Type (METSITE)  :: sites(2000)

      CONTAINS


C*************************************************************************                
C   routine to add a new site to the sites list
C*************************************************************************                
      Subroutine addSite2( id, column, row )
                                                                                          
         IMPLICIT NONE                                                                    

         !..INCLUDE FILES:
         INCLUDE SUBST_IOPARMS     ! IOAPI parameters
         INCLUDE SUBST_IOFDESC     ! IOAPI file description
         INCLUDE SUBST_IODECL      ! IOAPI declarations

         LOGICAL SETLAM          ! Sets up Lambert projection
         LOGICAL LAM2LL          ! Gets LAT/LON from Lambert projection

         Integer id, column, row

         REAL   X               ! x-coordinate for lambert projection
         REAL   Y               ! y-coordinate for lambert projection
         REAL   LONGITUDE       
         REAL   LATITUDE       

 
         !  set lambert projection
         IF( .NOT. SETLAM( SNGL(P_ALP3D), SNGL(P_BET3D), SNGL(P_GAM3D),
     &                    SNGL(XCENT3D), SNGL(YCENT3D) ) ) THEN
           CALL M3EXIT( 'O3TOIOAPI', 0, 0, 'Lambert projection setup error', 2 )
           ENDIF


         X = XORIG3D + (column-0.5) * XCELL3D
         Y = YORIG3D + (row-0.5) * YCELL3D

         !..get the lat/lon coordinates using lambert conversion
         IF( .NOT. LAM2LL( X, Y, longitude, latitude) ) THEN
           CALL M3EXIT( 'O3TOIOAPI', 0, 0,
     &                      'Lat/Lon to Lambert to conversion error', 2 )
           endif           

         Call addSite(id, longitude, latitude)
        
         RETURN
         END SUBROUTINE addSite2     

C*************************************************************************
C   routine to find the index number of a site 
C*************************************************************************
      Integer Function getSiteNumber( id ) result (siteNo)

         IMPLICIT NONE     

         Integer :: id
         Integer :: i

         siteNo = -1
 
         do i=1,NSITES
         if( id .eq. sites(i)%siteid ) then
           siteNo = i
           return
           endif
           Enddo 
      
         Return
         End Function getSiteNumber

C*************************************************************************                
C   routine to add a new site to the sites list
C*************************************************************************                
      Subroutine addSite( id, lon, lat )
                                                                                          
         IMPLICIT NONE                                                                    
                                                                                          
         Integer       :: id           
         Real          :: lon                                                   
         Real          :: lat                                                   

         if( NSITES .lt. SIZE(sites) ) then
           NSITES = NSITES + 1
           sites(NSITES)%siteid = id 
           sites(NSITES)%longitude = lon
           sites(NSITES)%latitude = lat
         else
           write(*,'(''**ERROR** site '',i10,
     &           '' Cannot be added, Maximum size exceeded'')') id
           endif

         return
         End Subroutine addSite
   
      END MODULE SITE_DATA
