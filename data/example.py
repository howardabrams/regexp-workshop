# But what does this game do? This is a game where you, as a player,
# think of an animal, and the computer will ask questions to try and
# guess what you are thinking.
#
# For complete documentation, see
# https://github.com/howardabrams/cookie-python/blob/master/Animal%20Guessing%20Game.ipynb

animals = {
    "question": "Does the animal you are thinking have four legs?",
    "no":  "fish",
    "yes": {
        "question": "Is your animal large and gray?",
        "yes": "elephant",
        "no": "cow"
    }
}

def playGame():
    print """Hi! I'm an animal guesser.

I will ask questions and try to guess what animal you are thinking.
Think of an animal. Got it in your head? Good!
"""

    while askYesNo("Would you like me to guess?"):
        walkTree(animals)    # playRound(animals)

def walkTree(branch):
    # Since we are currently at a branch, we can ask its question.
    direction = askYesNo( branch["question"] )
    newBranch = lowerBranch(branch, direction)

    # If answer to our question is not an animal, then we have another
    # branch, and we just recall this function with the new branch:
    # Otherwise, we end the game.

    if foundAnimal(newBranch):
        endGame(newBranch, branch, direction)
    else:
        walkTree(newBranch)

def lowerBranch(branch, direction):
    if direction:
        return branch["yes"]
    else:
        return branch["no"]

# assert( lowerBranch(animals, False) == "fish" )
#
# subbranch = lowerBranch(animals, True)
# assert( lowerBranch(subbranch, False) == "cow")
# assert( lowerBranch(subbranch, True) == "elephant")

def foundAnimal(branch):
    return not isinstance(branch, dict)

def endGame(branch, parent, direction):
    if askYesNo( "Is your animal " + showAnimal(branch) + "?" ):
        print "Yay! I guessed it!"
    else:
        storeNewAnimal(parent, whichSide(direction), branch)

def whichSide(yes):
    if yes:
        return "yes"
    else:
        return "no"

def showAnimal(animal):
    t = animal.lower()
    if t.startswith('a') or t.startswith('e') or t.startswith('i') or t.startswith('o') or t.startswith('u'):
        return "an " + animal
    else:
        return "a " + animal

def storeNewAnimal(higherBranch, side, oldAnimal):
    print "Shoot. What animal were you thinking?"
    newAnimal = raw_input().lower()

    print "What question could I ask to distinguish between", showAnimal(oldAnimal), "and", showAnimal(newAnimal), "?"
    newQuestion = raw_input()

    higherBranch[side] = {
        "question": turnIntoAQuestion(newQuestion),
        "yes": newAnimal,
        "no": oldAnimal
    }

def turnIntoAQuestion(words):
    if words.endswith("?"):
        return words
    else:
        return words + "?"

def isYes(answer):
    if answer.lower().startswith("y"):
        return True
    else:
        return False

def askYesNo(question):
    print question,
    return isYes( raw_input() )

playGame()
