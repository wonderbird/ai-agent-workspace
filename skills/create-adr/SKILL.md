---
name: create-adr
description: >
  Creates a structured Architecture Decision Record (ADR) from the current
  discussion or a given topic. Use when an architectural decision needs to be
  documented before implementation — covers drafting alternatives, consequences,
  mitigations, and decision drivers, then iteratively refines the document for
  clarity.
---
# Create an Architecture Decision Record (ADR)

## Your role

Act as a software architect experienced in preparing architectural decisions and presenting them to the decision makers.

Create and maintain a task list so that you can follow the next instructions carefully.

## Topic

$ARGUMENTS

## Goal

If the section "Topic" is empty and the current discussion does not clarify the scope of the architecture decision, then ask me for the decision to make.

The next goal is to move all information related to the undecided decision into an architecture decision record (ADR).

Please create the ADR and then present the result so that I can make the decision.

You MUST NOT implement a solution.

## Identify topic and filename

Please identify a good file name and headline for the ADR.

All ADR files are stored in `docs/architecture/decisions`. The file name must start with a three digit number starting at 001, for example: `001-file-name.md`.

## Research the Architecture Decision Record (ADR) method

Please crawl and understand the following documentation about architecture decisions and how to document them:

- https://docs.arc42.org/section-9/
- https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions
- https://adr.github.io/madr/

## Draft the ADR

From the chat, create a draft ADR following the format described in the crawled documentation.

IMPORTANT: The decision has not been made yet. The purpose of the document is to help stakeholders taking a well informed decision.

## Add frequently present alternative solutions

Double check whether the ADR contains the following alternative solutions:

- Ignore the problem and do nothing
- Investigate manual workarounds the user can apply
- Consider buying a product which solves the problem - if known, then list the alternatives already

For each solution not contained in the draft ADR yet:

1. Research the web about the positive and negative consequences of the solution
2. Integrate the solution into the ADR.
3. Ensure that the format and contents of the added content matches the quality of the existing solutions documented in the ADR.

## Mitigate negative consequences

For each solution in the ADR which lists negative consequences but does not address how they could be mitigated:

1. Think about possible ways to reduce or eliminate negative consequences
2. Update the ADR with a section about these mitigations

## Verify the decision drivers

Identify the decision drivers documented in the ADR until now. These are the factors most important to the stakeholders when making the decision.

If there are more than 5 decision drivers, the decision drivers should be prioritized and reduced in number. If there are fewer than 3 decision drivers, then more should be identified. The goal is to have 3-5 clear decision drivers.

Present the decision drivers to the user in a structured way. If there are less than 3 or more than 5 decision drivers, inform the user about the goal to have 3-5 of them.

Ask the user whether you should interview them in order to find out the correct decision drivers and their priority. During the interview ask questions, one by one, until you can update the decision drivers reliably with correct priority.

Then perform the update.

## Complete the ADR draft

Then think hard: What should be added to the ADR so that the entire decision related information including the different design aspects is preserved?

## Iterative restructuring for readability and understandability

Now start an iterative restructuring process with the goal of moving detailed information down and keeping higher level information further up in the document.

In every iteration check whether you can make the information on the upper document part simpler and refer to details at the bottom. After having moved some parts of the document, check whether it is still easy to follow and understand the document.

Repeat the restructuring iterations until you cannot see additional improvements.

## Final review and improvement

Finally, proof read the ADR. Think hard of how you could improve the document, so that it is easy to understand for a reader who is new to the topic. Then update the document.