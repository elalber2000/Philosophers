%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SÁNCHEZ PÉREZ ALBERTO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis of the different names in philosophy (mainly occidental)
% according to objective and subjective criteria

:- module(practice,_,[rfuzzy,clpr]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QUALIFIERS DEFINITIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
define_modifier(rather/2, TV_In, TV_Out) :-
	TV_Out .=. TV_In * TV_In.
define_modifier(very/2, TV_In, TV_Out) :-
	TV_Out .=. TV_In * TV_In * TV_In.
define_modifier(little/2, TV_In, TV_Out) :-
	TV_Out * TV_Out .=. TV_In.
define_modifier(very_little/2, TV_In, TV_Out) :-
	TV_Out * TV_Out * TV_Out .=. TV_In.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATA DEFINITION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


define_database(philosopher/8,
                [(name, rfuzzy_string_type),
                 (origin_country, rfuzzy_enum_type),
                 (antiquity, rfuzzy_integer_type),
                 (tediousness, rfuzzy_integer_type),
                 (misogyny, rfuzzy_integer_type),
                 (philosophical_movement, rfuzzy_enum_type),
                 (meme_rate, rfuzzy_integer_type),
                 (death, rfuzzy_enum_type)]).
                 
                 
% The main qualities we analyse are:
%   Name
%   Country of origin
%   Antiquity (Years between their birth and the current date)
%   How boring they are
%   How misogynistic they are
%   Their philosophical movement
%   Quantity of memes made about them
%   How they died

% To analyse subjective qualities (tediousness, misogyny and memes)
% We use analysis tools in google, which allows us to see the number
% of searchs and the "general feel" about those characteristics
% (this method can be upgraded but is more than enough for the scope of
% the project)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

philosopher(socrates, greece, 2490, 291, 152, classical, 2080, murder).
philosopher(st_thomas_aquinas, italy, 1205, 659, 155, scholasticism, 1960, murder).
philosopher(aristotle, greece, 1636, 340, 150, classical, 10300, disease).
philosopher(confucius, china, 1469, 118, 153, confucianism, 11200, unknown).
philosopher(descartes, france, 424, 291, 125, rationalism, 1780, murder).
philosopher(foucault, france, 94, 158, 3, postmodernism, 5850, disease).
philosopher(hume, scotland, 309, 217, 118, empirism, 4670, disease).
philosopher(kant, germany, 296, 446, 152, idealism, 7310, disease).
philosopher(kierkegaard, denmark, 207, 80, 103, negativism, 1050, disease).
philosopher(locke, uk, 388, 270, 83, empirism, 7040, disease).
philosopher(machiavelli, italy, 551, 115, 65, realism, 1050, disease).
philosopher(marx, germany, 202, 810, 240, materialism, 15700, disease).
philosopher(john_stuart_mill, uk, 214, 102, 7, utilitarism, 1730, disease).
philosopher(nietzsche, germany, 176, 281, 50, naturalism, 1730, disease).
philosopher(rousseau, switzerland, 308, 273, 125, social_contract, 25600, disease).
philosopher(sartre, france, 115, 475, 18, existentialism, 10800, disease).
philosopher(wittgenstein, austria, 131, 109, 71, positivism, 898, disease).
philosopher(leibniz, germany, 374, 73, 45, monism, 1900, unknown).
philosopher(hegel, germany, 250, 149, 96, idealism, 2670, disease).
philosopher(hobbes, uk, 432, 151, 140, materialism, 7730, disease).
philosopher(spinoza, holland, 388, 109, 105, monism, 3230, disease).
philosopher(simone_de_beauvoir, france, 112, 81, 0, existentialism, 1860, disease).
philosopher(heidegger, germany, 131, 120, 86, phenomenology, 1550, disease).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SIMILARITY BETWEEN DATA VALUES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Countries with common history
define_similarity_between(philosopher, origin_country(scotland), origin_country(uk), 0.3).
define_similarity_between(philosopher, origin_country(austria), origin_country(germany), 0.5).

% Categorization of deaths
define_similarity_between(philosopher, death(unknown), death(disease), 0.8).
define_similarity_between(philosopher, death(unknown), death(murder), 0.2).

% Similarity between philosophical movements
define_similarity_between(philosopher, philosophical_movement(phenomenology), philosophical_movement(idealism), 0.7).
define_similarity_between(philosopher, philosophical_movement(monism), philosophical_movement(materialism), 0.7).
define_similarity_between(philosopher, philosophical_movement(positivism), philosophical_movement(empirism), 0.9).
define_similarity_between(philosopher, philosophical_movement(negativism), philosophical_movement(idealism), 0.3).
define_similarity_between(philosopher, philosophical_movement(realism), philosophical_movement(materialism), 0.7).
define_similarity_between(philosopher, philosophical_movement(realism), philosophical_movement(empirism), 1).
define_similarity_between(philosopher, philosophical_movement(scholasticism), philosophical_movement(classical), 0.5).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUZZY FUNCTIONS DEFINITIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Historical eras
ancient(philosopher) :~ function(antiquity(philosopher), [(0,0), (1534,0), (1554,1), (5020,1)]).
medieval(philosopher) :~ function(antiquity(philosopher), [(0,0), (518,0), (538,1), (1534,1), (1554,0), (5020,0)]).
modern(philosopher) :~ function(antiquity(philosopher), [(0,0), (221,0), (241,1), (518,1), (538,0), (5020,0)]).
contemporary(philosopher) :~ function(antiquity(philosopher), [(0,1), (221,1), (241,0), (5020,0)]).

% Definition of fuzzy functions for different metrics
boring(philosopher) :~ function(tediousness(philosopher), [(0,0), (200,0), (300,1), (900,1)]).
sexist(philosopher) :~ function(misogyny(philosopher), [(0,0), (50,0), (100,1), (200,1)]).
memeable(philosopher) :~ function(meme_rate(philosopher), [(0,0), (4000,0), (10000,1), (20000,1)]).

% We rule how loved/hated a philosopher is according to different characteristics
hated(philosopher) :~ rule(min, (boring(philosopher), fnot(very(memeable(philosopher))))).
hated(philosopher) :~ value(1) if (death(philosopher) equals murder).
loved(philosopher) :~ antonym_of(hated(philosopher), prod, 0.8).

% We define if the philosopher is european
european(philosopher) :~ defaults_to(1).
european(philosopher) :~ value(0) if (origin_country(philosopher) equals china).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QUERIES, SEARCHES, RESULTS AND CONCLUSIONS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%...  use Esc+X comment-region     
%...  use Esc+X uncomment-region


% Query examples


% I'm looking for a philosopher
% -memeable
% -fairly ancient
%
%   Aristotle
%
%
%
% I'm looking for a philosopher
% -loved
% -very sexist
%
%   Aristotle
%   Confucius
%   Kierkegaard
%   Hobbes
%   Spinoza
%
%
%
% I'm looking for a philosopher
% -modern
% -death = murdered
%
%   Descartes
%
%
%
% I'm looking for a philosopher
% -boring
% -loved
% -philosophical_movement =/= existentialism
%
%   Aristotle
%   Marx
%
%
%
% I'm looking for a philosopher
% -boring
% -death == murder
%
%   Sth Thomas Aquinas
%   Socrates
%   Descartes
%
%
%
% I'm looking for a philosopher
% -origin_country = france
% -not sexist
%
%   Foucault
%   Sartre
%   Simone de Beauvoir



% Silly conclusions:
%   -There is no correlation between the year of birth and the quantity of memes made
%   about a philosopher
%
%   -Most philosophers died because of a disease. (duh)
%
%   -Surprisingly, misogyny and tediousness dont really influence how loved a philosopher is
%
%   -All murdered philosophers (St Thomas, Socrates and Descartes) were incredibly boring and
%   misogynistic terriblemente aburridos y misóginos.
%
%   -Idealistic philosophers are as boring as materialistic ones, but more misogynistic
%
%   -Except Descartes, french philosophers aren not really misogynistic.


% Note: The model is not really big, so most conclusions may be slanted. The idea of the project
% was learning fuzzy prolog and having some fun with it.






