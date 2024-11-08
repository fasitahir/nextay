CREATE TRIGGER trg_CheckBookingOccupancy
ON [dbo].[Booking]
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @RoomID INT, @NumberOfGuests INT, @MaxOccupancy INT;

    -- Get the values from the inserted or updated row
    SELECT @RoomID = RoomID, @NumberOfGuests = NumberOfGuests FROM inserted;

    -- Ensure the correct column references
    SELECT @MaxOccupancy = MaxOccupancy FROM [dbo].[Rooms] AS r WHERE r.RoomID = @RoomID;

    -- Check if the number of guests exceeds the room's max occupancy
    IF @NumberOfGuests > @MaxOccupancy
    BEGIN
        PRINT 'Error: Number of guests exceeds the room''s maximum occupancy.';
        ROLLBACK; -- Reject the insert or update
    END
END;
