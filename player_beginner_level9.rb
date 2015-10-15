# This class will defeat all enemies and rescue all captives of level 9
# https://www.bloc.io/ruby-warrior - beginner mode
#
# To beat lower levels with it, uncomment in the play_turn method
# the methods that contain yet unavailable warrior abilities
# and maybe alter the other pieces slightly

class Player
  attr_reader :warrior, :health, :previous_health, :direction, :hit_wall

  def play_turn(warrior)
    @warrior = warrior
    update_health

    # the following methods have to
    # - return true when an action! is done
    # - return false when no action! is done
    # the order in which they are called is significant!

    update_direction            ||
      shoot_when_enemy_in_range ||
      rest                      ||
      proceed                   ||
      run_away                  ||
      rescue_or_proceed         ||
      attack!
  end

  private

  def update_health
    @previous_health = health
    @health = warrior.health
  end

  # -------- action methods below (return true when an action! is called)

  def shoot_when_enemy_in_range
    shoot!(direction)        and return true  if enemy_in_range?(direction)
    shoot!(other_direction)  and return true  if enemy_in_range?(other_direction)

    false
  end

  def update_direction(dir = other_direction)
    if direction.nil?
      @direction = other_direction(dir)
      # when should this be done? (fighting backwards is less effective)
      # warrior.pivot! and return true
    end

    if space_wall?
      @hit_wall = true
      turn_around!
      return true
    elsif space_stairs? && !hit_wall  # explore the whole level first
      turn_around!
      return true
    end

    false
  end

  def rest
    rest! and return true  unless taking_damage? || healthy?

    false
  end

  def proceed
    walk! and return true  if space_empty? && (healthy? || (taking_damage? && !low_health?))

    false
  end

  def run_away
    run_away! and return true  if low_health? && taking_damage?

    false
  end

  def rescue_or_proceed
    walk!           and return true  if captive? && taking_damage?
    rescue_captive! and return true  if captive?

    false
  end

  # ------- helper methods

  def enemy_in_range?(dir = direction)
    spaces = warrior.look(dir)

    spaces.each do |space|
      return true if space.enemy?     # when an enemy is visible, we return directly to shoot
      return false if space.captive?  # when a captive is visible, we return directly to not shoot him
    end

    false
  end

  def taking_damage?
    return false if previous_health.nil?

    health < previous_health
  end

  def other_direction(dir = direction)
    dir == :forward ? :backward : :forward
  end

  def turn_around!
    warrior.pivot!(other_direction)
    @direction = other_direction
  end

  # ----------- methods to encapsulate warrior abilities 

  def shoot!(dir = direction)
    warrior.shoot!(dir)
  end

  def run_away!
    warrior.walk!(other_direction)
  end

  def rest!
    warrior.rest!
  end

  def healthy?
    warrior.health > 19
  end

  def low_health?
    warrior.health < 10
  end

  def space_wall?
    warrior.feel(direction).wall?
  end

  def space_stairs?
    warrior.feel(direction).stairs?
  end

  def space_empty?
    warrior.feel(direction).empty?
  end

  def captive?
    warrior.feel(direction).captive?
  end

  def rescue_captive!
    warrior.rescue!(direction)
  end

  def attack!
    warrior.attack!(direction)
  end

  def walk!
    warrior.walk!(direction)
  end
end
