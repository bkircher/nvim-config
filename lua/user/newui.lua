-- Enable experimental new UI (≥ 0.12.0). See `:help ui2`
--
-- Reduces the press-enter interruptions, adds proper command line
-- highlighting, and the pager becomes a normal buffer which we can yank from.
--
-- Type `g<` to move into the output.

require("vim._core.ui2").enable({})
